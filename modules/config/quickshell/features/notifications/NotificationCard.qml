pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import "../../theme"
import "../../ui/controls"

ActionButton {
    id: root
    required property NotificationRecord notification
    property bool toastMode: false
    signal dismissRequested
    signal actionRequested(string actionId)

    padding: Theme.spacing.large
    fillColor: root.toastMode ? Theme.colors.surface : Theme.colors.surfaceVariant
    cornerRadius: Theme.shape.controlRadius
    implicitHeight: implicitContentHeight + topPadding + bottomPadding

    HoverHandler {
        onHoveredChanged: {
            if (root.toastMode && root.notification)
                root.notification.toast.setPaused(root, hovered);
        }
    }
    Component.onDestruction: {
        if (root.notification)
            root.notification.toast.setPaused(root, false);
    }

    contentItem: ColumnLayout {
        spacing: Theme.spacing.medium
        RowLayout {
            Layout.fillWidth: true
            IconView {
                source: root.notification.image || root.notification.appIcon
                fallbackGlyph: "󰂚"
                Layout.preferredWidth: Theme.components.iconButton.size
                Layout.preferredHeight: Theme.components.iconButton.size
            }
            TextLabel {
                text: root.notification.appName
                font.bold: true
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
            TextLabel {
                text: Qt.formatDateTime(new Date(root.notification.receivedAt), "hh:mm")
                font: Theme.typography.caption
                color: Theme.colors.textSecondary
            }
            IconButton {
                compact: true
                glyph: "󰅖"
                tooltipText: root.toastMode ? "收起通知" : "删除通知"
                onClicked: root.dismissRequested()
            }
        }
        TextLabel {
            visible: text.length > 0
            text: root.notification.summary
            font.bold: true
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
        TextLabel {
            visible: text.length > 0
            text: root.notification.body
            textFormat: Text.StyledText
            wrapMode: Text.Wrap
            maximumLineCount: root.toastMode ? 4 : 8
            elide: Text.ElideRight
            color: Theme.colors.textSecondary
            Layout.fillWidth: true
        }
        Flow {
            Layout.fillWidth: true
            spacing: Theme.spacing.small
            visible: root.notification.actions.length > 0
            Repeater {
                model: root.notification.actions
                delegate: ActionButton {
                    required property var modelData
                    text: modelData.text || modelData.identifier
                    tonal: true
                    onClicked: root.actionRequested(modelData.identifier)
                }
            }
        }
        Rectangle {
            visible: root.toastMode && root.notification.toast.duration > 0
            Layout.fillWidth: true
            implicitHeight: Theme.spacing.tiny
            color: Theme.colors.surfaceVariant
            Rectangle {
                width: parent.width * root.notification.toast.progress
                height: parent.height
                color: Theme.components.notification.urgencyColor(root.notification.urgency)
            }
        }
    }
}
