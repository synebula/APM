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

        const focused = candidates.find(window => {
            return window.focused;
        });
        root.windows = focused ? [focused].concat(candidates.filter(window => {
            return window !== focused;
        })) : candidates;
        root.selectedIndex = (direction < 0 ? root.windows.length - 1 : 1) % root.windows.length;
        root.isOpen = true;
    }

    function cycle(direction, wsOnly) {
        if (!root.isOpen)
            root.open(direction, wsOnly);
        else if (root.windows.length)
            root.selectedIndex = (root.selectedIndex + direction + root.windows.length) % root.windows.length;
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

            root.windows = root.windows.filter(window => {
                return window && WindowManagerService.windows.includes(window);
            });
            root.selectedIndex = Math.min(root.selectedIndex, root.windows.length - 1);
            if (!root.windows.length)
                root.close();
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
