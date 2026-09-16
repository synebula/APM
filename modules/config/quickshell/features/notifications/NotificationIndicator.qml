import "../../services"
import "../../theme"
import "../../ui/controls"
import QtQuick
import Quickshell

BarButton {
    id: root

    property var barWindow: null
    property var anchorItem: root

    tooltipText: {
        const count = NotificationService.unreadCount;
        const dndText = NotificationService.doNotDisturb ? " [DND]" : "";
        return "NotificationToastWindow: " + (count > 0 ? (count + " unread") : "No new") + dndText + " (Click: Center // Right-click: DND)";
    }
    function toggleMenu() {
        if (!notifMenuLoader.active) {
            notifMenuLoader.active = true;
            if (notifMenuLoader.item)
                notifMenuLoader.item.open();
        } else if (notifMenuLoader.item) {
            notifMenuLoader.item.toggle();
        }
    }

    onClicked: root.toggleMenu()
    onRightClicked: NotificationService.toggleDoNotDisturb()

    Connections {
        target: NotificationService
        function onToggleCenterRequested() {
            if (!root.barWindow || !WindowManagerService.focusedScreen || root.barWindow.screen === WindowManagerService.focusedScreen)
                root.toggleMenu();
        }
    }

    Loader {
        id: notifMenuLoader
        active: false
        sourceComponent: Component {
            NotificationCenterPopup {
                anchorItem: root.anchorItem
                barWindow: root.barWindow
            }
        }
    }

    content: BarText {
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined
        text: NotificationService.doNotDisturb ? "󰂛" : (NotificationService.unreadCount > 0 ? ("󰂚 " + NotificationService.unreadCount) : "󰂚")
        color: NotificationService.doNotDisturb ? Theme.colors.danger : ((NotificationService.unreadCount > 0) ? Theme.colors.accent : Theme.colors.textPrimary)
        font.pixelSize: Theme.typography.bodySize
    }
}
