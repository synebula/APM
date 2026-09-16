pragma Singleton
import QtQuick
import Quickshell

import "./windowmanager"
import "./TrayWindowMatcher.js" as TrayWindowMatcher

Singleton {
    id: root

    readonly property string backendName: Quickshell.env("NIRI_SOCKET") ? "niri" : (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") ? "hyprland" : "generic")
    readonly property WindowManagerBackend backend: backendLoader.item as WindowManagerBackend
    readonly property bool available: root.backend !== null && root.backend.available
    readonly property list<WindowInfo> windows: root.backend ? root.backend.windows : []
    readonly property list<WorkspaceInfo> workspaces: root.backend ? root.backend.workspaces : []
    readonly property WindowInfo activeWindow: root.backend ? root.backend.activeWindow : null
    readonly property string activeWindowId: root.activeWindow ? root.activeWindow.windowId : ""
    readonly property WorkspaceInfo focusedWorkspace: root.backend ? root.backend.focusedWorkspace : null
    readonly property string focusedWorkspaceId: root.focusedWorkspace ? root.focusedWorkspace.workspaceId : ""
    readonly property var focusedScreen: Quickshell.screens.find(screen => root.focusedWorkspace && screen.name === root.focusedWorkspace.outputName) || Quickshell.screens[0] || null

    function workspaceNamed(name, screenName) {
        if (!name)
            return null;
        const target = String(name);
        if (screenName) {
            const scopedNamed = root.workspaces.find(workspace => workspace.name === target && workspace.isNamed && workspace.outputName === screenName);
            if (scopedNamed)
                return scopedNamed;
            const scoped = root.workspaces.find(workspace => workspace.name === target && workspace.outputName === screenName);
            if (scoped)
                return scoped;
        }
        return root.workspaces.find(workspace => workspace.name === target && workspace.isNamed)
            || root.workspaces.find(workspace => workspace.name === target)
            || null;
    }

    function activeWorkspaceForScreen(screen) {
        return root.workspaces.find(workspace => workspace.active && (!screen || workspace.outputName === screen.name)) || null;
    }

    function windowsForWorkspace(name, screenName) {
        const workspace = root.workspaceNamed(name, screenName);
        return workspace ? root.windows.filter(window => window.workspaceId === workspace.workspaceId) : [];
    }

    function windowsForScreen(screen) {
        return root.windows.filter(window => !screen || !window.outputName || window.outputName === screen.name);
    }

    function switchWorkspace(name: string) {
        if (root.available)
            root.backend.switchWorkspaceRequested(name);
    }
    function focusWindow(windowId: string) {
        if (root.available && windowId)
            root.backend.focusWindowRequested(windowId);
    }
    function closeWindow(windowId: string) {
        if (root.available && windowId)
            root.backend.closeWindowRequested(windowId);
    }
    function focusApplication(appId: string): bool {
        const target = appId.toLowerCase().replace(/\.desktop$/, "");
        if (!target)
            return false;
        const window = root.windows.find(item => item.appId.toLowerCase() === target) || root.windows.find(item => item.appId.toLowerCase().includes(target));
        if (!window)
            return false;
        root.focusWindow(window.windowId);
        return true;
    }
    function findWindowForTray(trayItem) {
        return TrayWindowMatcher.match(root.windows, trayItem);
    }
    function focusTrayItem(trayItem): bool {
        const window = root.findWindowForTray(trayItem);
        if (!window)
            return false;
        root.focusWindow(window.windowId);
        return true;
    }
    function exitSession(): bool {
        if (!root.available)
            return false;
        root.backend.exitSessionRequested();
        return true;
    }

    Loader {
        id: backendLoader
        sourceComponent: root.backendName === "niri" ? niriBackend : (root.backendName === "hyprland" ? hyprlandBackend : genericBackend)
    }
    Component {
        id: niriBackend
        NiriBackend {}
    }
    Component {
        id: hyprlandBackend
        HyprlandBackend {}
    }
    Component {
        id: genericBackend
        WindowManagerBackend {}
    }
}
