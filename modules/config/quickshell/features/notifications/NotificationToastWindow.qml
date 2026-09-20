pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland

import "../../config"
import "../../services"
import "../../theme"
import "../../ui/controls"
import "../../ui/effects"

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
    implicitWidth: Theme.components.notification.cardWidth
    implicitHeight: notifications.implicitHeight
    readonly property bool isTargetScreen: !ShellSettings.toastsOnFocusedScreenOnly || !WindowManagerService.focusedWorkspace || !root.screen || root.screen.name === WindowManagerService.focusedWorkspace.outputName
    visible: NotificationService.toasts.length > 0 && isTargetScreen
    color: "transparent"

    // 卡片注册表：委托按序登记，供模糊区域槽位引用；
    // Repeater 对 JS 数组模型是整体重建，itemAt/children 均无可依赖的变更通知。
    property var toastCards: []

    function registerToastCard(card) {
        const next = root.toastCards.slice();
        next.push(card);
        root.toastCards = next;
    }

    function unregisterToastCard(card) {
        const idx = root.toastCards.indexOf(card);
        if (idx === -1)
            return;
        const next = root.toastCards.slice();
        next.splice(idx, 1);
        root.toastCards = next;
    }

    // 逐卡片并集模糊：槽位数须与 ShellSettings.notificationToastLimit 一致，
    // 缺失/隐藏槽位以 null item 退出并集，卡片间隙不再被误模糊。
    CompositorBlurRegion {
        targetWindow: root
        radius: Theme.shape.controlRadius

        Region { item: root.toastCards.length > 0 ? root.toastCards[0] : null; radius: Theme.shape.controlRadius }
        Region { item: root.toastCards.length > 1 ? root.toastCards[1] : null; radius: Theme.shape.controlRadius }
        Region { item: root.toastCards.length > 2 ? root.toastCards[2] : null; radius: Theme.shape.controlRadius }
        Region { item: root.toastCards.length > 3 ? root.toastCards[3] : null; radius: Theme.shape.controlRadius }
        Region { item: overflowBadge.visible ? overflowBadge : null; radius: Theme.shape.controlRadius }
    }

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
                toastWindow: root
                onClicked: NotificationService.activate(modelData.notificationId)
                onDismissRequested: modelData.toast.hide()
                onActionRequested: actionId => NotificationService.invokeAction(modelData.notificationId, actionId)
            }
        }
        Rectangle {
            id: overflowBadge

            visible: NotificationService.toasts.length > ShellSettings.notificationToastLimit
            anchors.horizontalCenter: parent.horizontalCenter
            implicitWidth: overflowText.implicitWidth + Theme.spacing.large * 2
            implicitHeight: Theme.components.notification.overflowBadgeHeight
            radius: implicitHeight / 2
            color: Theme.components.notification.cardBackground(true, false, false, 1)
            border.width: 1
            border.color: Theme.colors.outline

            TextLabel {
                id: overflowText
                anchors.centerIn: parent
                text: "+" + (NotificationService.toasts.length - ShellSettings.notificationToastLimit) + " 条通知，可在通知中心查看"
                font: Theme.typography.caption
                color: Theme.colors.textSecondary
            }
        }
    }
}
