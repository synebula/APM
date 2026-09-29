import "../../config"
import "../../services"
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property bool isOpen: false
    property var windows: []
    property int selectedIndex: 0
    property bool currentWorkspaceOnly: false

    function open(direction, wsOnly) {
        root.currentWorkspaceOnly = !!wsOnly;
        const targetWsId = root.currentWorkspaceOnly ? WindowManagerService.focusedWorkspaceId : "";
        const candidates = WindowManagerService.windows.filter(window => {
            if (!ShellSettings.showInTaskbar(window.appId))
                return false;
            if (root.currentWorkspaceOnly && targetWsId)
                return window.workspaceId === targetWsId;
            return true;
        });
        if (!candidates.length)
            return;

        root.windows = candidates;
        const focusedIndex = candidates.findIndex(window => {
            return window.focused;
        });
        if (focusedIndex >= 0)
            root.selectedIndex = ((focusedIndex + direction) % candidates.length + candidates.length) % candidates.length;
        else
            root.selectedIndex = direction < 0 ? candidates.length - 1 : 0;
        root.isOpen = true;
    }

    function cycle(direction, wsOnly) {
        if (!root.isOpen)
            root.open(direction, wsOnly);
        else if (root.windows.length)
            root.selectedIndex = ((root.selectedIndex + direction) % root.windows.length + root.windows.length) % root.windows.length;
    }

    function close() {
        root.isOpen = false;
    }

    function commit() {
        const window = root.windows[root.selectedIndex];
        root.close();
        if (window)
            WindowManagerService.focusWindow(window.windowId);
    }

    Connections {
        function onWindowsChanged() {
            if (!root.isOpen)
                return;

            const selectedWindow = root.windows[root.selectedIndex];
            root.windows = root.windows.filter(window => {
                return window && WindowManagerService.windows.includes(window);
            });
            if (!root.windows.length) {
                root.close();
                return;
            }
            const newIndex = root.windows.indexOf(selectedWindow);
            root.selectedIndex = newIndex >= 0 ? newIndex : Math.min(root.selectedIndex, root.windows.length - 1);
        }

        target: WindowManagerService
    }

    IpcHandler {
        function toggle() {
            if (root.isOpen)
                root.close();
            else
                root.open(1, false);
        }

        function next() {
            root.cycle(1, false);
        }

        function prev() {
            root.cycle(-1, false);
        }

        function nextCurrentWorkspace() {
            root.cycle(1, true);
        }

        function prevCurrentWorkspace() {
            root.cycle(-1, true);
        }

        function open() {
            root.open(1, false);
        }

        function close() {
            root.close();
        }

        function commit() {
            root.commit();
        }

        target: "switcher"
    }
}
