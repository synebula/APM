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

    content: Row {
        spacing: Theme.spacing.tiny
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined

        IconGlyph {
            anchors.verticalCenter: parent.verticalCenter
            text: NotificationService.doNotDisturb ? "󰂛" : "󰂚"
            color: Theme.components.notification.indicatorTone(NotificationService.doNotDisturb, NotificationService.unreadCount > 0)
            font.pixelSize: Theme.typography.bodySize
        }

        BarText {
            visible: !NotificationService.doNotDisturb && NotificationService.unreadCount > 0
            anchors.verticalCenter: parent.verticalCenter
            text: NotificationService.unreadCount.toString()
            color: Theme.components.notification.indicatorTone(false, true)
        }
    }
}
