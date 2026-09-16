pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland

import "../../config"
import "../../services"
import "../../theme"
import "../../ui/controls"

PanelWindow {
    id: root
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-notifications"
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    anchors {
        top: true
        // right: true
    }
    margins.top: Theme.components.bar.height + Theme.spacing.medium
    margins.right: Theme.spacing.medium
    implicitWidth: 420 * Theme.controlScale
    implicitHeight: notifications.implicitHeight
    readonly property bool isTargetScreen: !ShellSettings.toastsOnFocusedScreenOnly || !WindowManagerService.focusedScreen || !root.screen || root.screen === WindowManagerService.focusedScreen || root.screen.name === WindowManagerService.focusedScreen.name
    visible: NotificationService.toasts.length > 0 && isTargetScreen
    color: "transparent"

    Column {
        id: notifications
        width: parent.width
        spacing: Theme.spacing.medium
        Repeater {
            model: NotificationService.toasts.slice(0, ShellSettings.notificationToastLimit)
            delegate: NotificationCard {
                required property var modelData
                width: notifications.width
                notification: modelData
                toastMode: true
                onClicked: NotificationService.activate(modelData.notificationId)
                onDismissRequested: modelData.toast.hide()
                onActionRequested: actionId => NotificationService.invokeAction(modelData.notificationId, actionId)
            }
        }
        TextLabel {
            visible: NotificationService.toasts.length > ShellSettings.notificationToastLimit
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: "+" + (NotificationService.toasts.length - ShellSettings.notificationToastLimit) + " 条通知，可在通知中心查看"
            color: Theme.colors.textSecondary
        }
    }
}
