pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import "../../theme"
import "../../ui/containers"
import "../../ui/controllers"
import "../../ui/controls"

PopupPanel {
    id: root
    contentWidth: 480 * Theme.controlScale
    contentHeight: Math.min(640 * Theme.controlScale, content.implicitHeight + Theme.components.popup.padding * 2)
    onIsOpenChanged: NotificationService.centerOpen = isOpen

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: Theme.components.popup.padding
        spacing: Theme.spacing.large

        SectionHeader {
            Layout.fillWidth: true
            title: "通知"
            subtitle: NotificationService.doNotDisturb ? "勿扰模式已开启" : NotificationService.records.length + " 条通知"
            glyph: "󰂚"
            IconButton {
                glyph: "󰂛"
                checked: NotificationService.doNotDisturb
                tooltipText: "切换勿扰模式"
                onClicked: NotificationService.toggleDoNotDisturb()
            }
            IconButton {
                glyph: "󰆴"
                tooltipText: "清空通知"
                enabled: NotificationService.records.length > 0
                destructive: true
                onClicked: NotificationService.clearAll()
            }
        }

        Divider {
            Layout.fillWidth: true
        }

        TextLabel {
            visible: NotificationService.records.length === 0
            text: "没有新通知"
            color: Theme.colors.textSecondary
            horizontalAlignment: Text.AlignHCenter
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.components.actionRow.height * 2
            verticalAlignment: Text.AlignVCenter
        }

        ListView {
            id: history
            visible: count > 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: Math.min(contentHeight, 460 * Theme.controlScale)
            model: NotificationService.records
            spacing: Theme.spacing.medium
            clip: true
            reuseItems: true
            boundsBehavior: Flickable.StopAtBounds
            WheelScrollController {
                flickable: history
            }
            delegate: NotificationCard {
                required property var modelData
                width: history.width
                notification: modelData
                onClicked: {
                    root.close();
                    NotificationService.activate(modelData.notificationId);
                }
                onDismissRequested: NotificationService.dismiss(modelData.notificationId)
                onActionRequested: actionId => NotificationService.invokeAction(modelData.notificationId, actionId)
            }
        }
    }
}
