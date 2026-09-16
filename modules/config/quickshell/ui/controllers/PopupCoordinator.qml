pragma Singleton
import "../../services"
import QtQuick
import Quickshell

Singleton {
    id: root

    property var activePopup: null
    property string windowIdAtOpen: ""

    function activate(popup) {
        if (root.activePopup && root.activePopup !== popup)
            root.activePopup.close();

        root.activePopup = popup;
        root.windowIdAtOpen = WindowManagerService.activeWindowId;
    }

    function release(popup) {
        if (root.activePopup === popup)
            root.activePopup = null;
    }

    function closeActive() {
        if (root.activePopup)
            root.activePopup.close();
    }

    Connections {
        function onActiveWindowIdChanged() {
            const current = WindowManagerService.activeWindowId;
            if (root.windowIdAtOpen && current && current !== root.windowIdAtOpen)
                root.closeActive();
        }

        function onFocusedWorkspaceIdChanged() {
            root.closeActive();
        }

        target: WindowManagerService
    }
}
