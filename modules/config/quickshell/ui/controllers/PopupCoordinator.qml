pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property var activePopup: null
    // The popup registry is global, but the backdrop is instantiated once per screen.
    // Keep ownership explicit so a popup opened from one bar cannot block another.
    property string activeScreenName: ""

    function screenNameFor(popup) {
        if (!popup)
            return "";
        try {
            const candidates = [
                popup.barWindow ? popup.barWindow.screen : null,
                popup.ownerScreen,
                popup.screen
            ];
            for (const screen of candidates) {
                if (screen && screen.name)
                    return String(screen.name);
            }
        } catch (error) {
            console.warn("PopupCoordinator: cannot resolve popup screen:", error);
        }
        return "";
    }

    function screenExists(name) {
        if (!name)
            return false;
        return Quickshell.screens.some(screen => screen && screen.name === name);
    }

    function activate(popup) {
        if (root.activePopup && root.activePopup !== popup)
            root.activePopup.close();

        root.activePopup = popup;
        root.activeScreenName = root.screenNameFor(popup);
    }

    function release(popup) {
        if (root.activePopup === popup) {
            root.activePopup = null;
            root.activeScreenName = "";
        }
    }

    function closeActive() {
        if (root.activePopup)
            root.activePopup.close();
    }

    Connections {
        target: Quickshell

        function onScreensChanged() {
            if (!root.activePopup || root.screenExists(root.activeScreenName))
                return;

            const popup = root.activePopup;
            root.activePopup = null;
            root.activeScreenName = "";
            popup.close();
        }
    }

}
