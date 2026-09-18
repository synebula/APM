pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import "../../theme"
import "../../ui/containers"
import "../../ui/controllers"
import "../../ui/controls"

PopupPanel {
    id: root
    contentWidth: 560 * Theme.controlScale
    contentHeight: Math.min(720 * Theme.controlScale, content.implicitHeight + Theme.components.popup.padding * 2)
    onIsOpenChanged: NotificationService.centerOpen = isOpen

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: Theme.components.popup.padding
        spacing: Theme.spacing.large

        SectionHeader {
            Layout.fillWidth: true
            title: "通知"
            subtitle: NotificationService.doNotDisturb ? "勿扰模式已开启" : (NotificationService.records.length > 0 ? (NotificationService.records.length + " 条通知") : "全部已读")
            glyph: NotificationService.doNotDisturb ? "󰂛" : "󰂚"
            tone: Theme.components.notification.centerStatusTone(NotificationService.doNotDisturb, NotificationService.records.length > 0)
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

        ColumnLayout {
            visible: NotificationService.records.length === 0
            Layout.fillWidth: true
            Layout.preferredHeight: 180 * Theme.controlScale
            spacing: Theme.spacing.medium
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter

            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: 48 * Theme.controlScale
                implicitHeight: implicitWidth
                radius: implicitWidth / 2
                color: Theme.components.notification.emptyBadgeColor(NotificationService.doNotDisturb)

                IconGlyph {
                    anchors.centerIn: parent
                    text: NotificationService.doNotDisturb ? "󰂛" : "󰂚"
                    color: Theme.components.notification.centerStatusTone(NotificationService.doNotDisturb, false)
                    font.pixelSize: 22 * Theme.fontScale
                }
            }

            TextLabel {
                Layout.alignment: Qt.AlignHCenter
                text: NotificationService.doNotDisturb ? "勿扰模式开启中" : "暂无新通知"
                font.bold: true
                font.pixelSize: Theme.typography.bodySize
                color: Theme.colors.textPrimary
            }

            TextLabel {
                Layout.alignment: Qt.AlignHCenter
                text: ""
                font: Theme.typography.caption
                color: Theme.colors.textSecondary
            }
        }

        ListView {
            id: history
            visible: count > 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: contentHeight
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
