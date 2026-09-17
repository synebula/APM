pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell

import "../../theme"
import "../../ui/controls"

ActionButton {
    id: root
    required property NotificationRecord notification
    property bool toastMode: false
    signal dismissRequested
    signal actionRequested(string actionId)

    readonly property bool isUrgent: root.notification && root.notification.urgency === 2
    readonly property bool isUnread: root.notification && root.notification.unread
    readonly property int notificationUrgency: root.notification ? root.notification.urgency : 1
    readonly property bool hasImage: !!(root.notification && root.notification.image && root.notification.image.length > 0)
    readonly property string resolvedImage: {
        if (!root.hasImage)
            return "";
        const img = root.notification.image;
        if (img.startsWith("/"))
            return "file://" + img;
        if (img.includes("://"))
            return img;
        return Quickshell.iconPath(img, true) || img;
    }

    topPadding: Theme.spacing.large
    bottomPadding: Theme.spacing.large
    leftPadding: Theme.spacing.large + 6
    rightPadding: Theme.spacing.large

    fillColor: Theme.components.notification.cardBackground(root.toastMode, root.isUnread, root.hovered, root.notificationUrgency)
    borderWidth: 1
    borderColor: Theme.components.notification.cardBorderColor(root.toastMode, root.isUnread, root.hovered, root.notificationUrgency)
    foreground: Theme.components.notification.appNameColor(root.notificationUrgency)
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

    Rectangle {
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            leftMargin: 4
            topMargin: 8
            bottomMargin: 8
        }
        width: 3
        radius: 1.5
        color: Theme.components.notification.accentStripColor(root.isUnread, root.notificationUrgency)
    }

    contentItem: ColumnLayout {
        spacing: Theme.spacing.medium

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            Rectangle {
                Layout.preferredWidth: Theme.components.iconButton.size
                Layout.preferredHeight: Theme.components.iconButton.size
                radius: Theme.shape.smallRadius
                color: Theme.components.notification.iconContainerColor(root.notificationUrgency)

                IconView {
                    anchors.centerIn: parent
                    width: Theme.components.iconButton.iconSize
                    height: Theme.components.iconButton.iconSize
                    source: root.notification ? root.notification.appIcon : ""
                    fallbackGlyph: "󰂚"
                    foreground: Theme.components.notification.iconGlyphColor(root.notificationUrgency)
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.small

                    TextLabel {
                        text: root.notification ? root.notification.appName : ""
                        font.bold: true
                        font.pixelSize: Theme.typography.captionSize
                        color: Theme.components.notification.appNameColor(root.notificationUrgency)
                        elide: Text.ElideRight
                    }

                    Rectangle {
                        visible: root.isUnread
                        implicitWidth: 6
                        implicitHeight: 6
                        radius: 3
                        color: Theme.colors.accent
                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    TextLabel {
                        text: root.notification ? Qt.formatDateTime(new Date(root.notification.receivedAt), "hh:mm") : ""
                        font: Theme.typography.caption
                        color: Theme.colors.textSecondary
                    }
                }
            }

            IconButton {
                compact: true
                glyph: "󰅖"
                tooltipText: root.toastMode ? "收起通知" : "删除通知"
                onClicked: root.dismissRequested()
            }
        }

        TextLabel {
            id: summaryLabel
            visible: text.length > 0
            text: root.notification ? root.notification.summary : ""
            font.bold: true
            font.pixelSize: Theme.typography.bodySize
            color: Theme.colors.textPrimary
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        TextLabel {
            id: bodyLabel
            visible: text.length > 0
            text: root.notification ? root.notification.body : ""
            textFormat: Text.StyledText
            wrapMode: Text.Wrap
            maximumLineCount: root.toastMode ? 4 : 8
            elide: Text.ElideRight
            color: Theme.colors.textSecondary
            Layout.fillWidth: true
            Layout.topMargin: (root.notification && root.notification.summary.length > 0) ? -Theme.spacing.small : 0
        }

        Rectangle {
            id: imageContainer
            visible: root.hasImage && previewImage.status === Image.Ready
            Layout.fillWidth: true
            Layout.preferredHeight: {
                if (!visible || previewImage.implicitWidth <= 0)
                    return 0;
                const cardWidth = width > 0 ? width : (360 * Theme.controlScale);
                const maxHeight = (root.toastMode ? 160 : 180) * Theme.controlScale;
                const naturalHeight = previewImage.implicitWidth > cardWidth ? previewImage.implicitHeight * (cardWidth / previewImage.implicitWidth) : Math.min(previewImage.implicitHeight, previewImage.implicitHeight * (cardWidth / previewImage.implicitWidth));
                return Math.min(maxHeight, Math.max(48 * Theme.controlScale, naturalHeight));
            }
            radius: Theme.shape.controlRadius
            color: Theme.colors.surfaceVariant
            border.width: 1
            border.color: Theme.colors.outline
            clip: true

            Image {
                anchors.fill: parent
                source: previewImage.source
                fillMode: Image.PreserveAspectCrop
                opacity: 0.18
                asynchronous: true
            }

            Image {
                id: previewImage
                anchors.fill: parent
                source: root.resolvedImage
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                mipmap: true
            }
        }

        Flow {
            Layout.fillWidth: true
            spacing: Theme.spacing.small
            visible: root.notification && root.notification.actions && root.notification.actions.length > 0
            Repeater {
                model: root.notification ? root.notification.actions : []
                delegate: ActionButton {
                    required property var modelData
                    text: modelData.text || modelData.identifier
                    tonal: true
                    onClicked: root.actionRequested(modelData.identifier)
                }
            }
        }

        Rectangle {
            visible: root.toastMode && root.notification && root.notification.toast.duration > 0
            Layout.fillWidth: true
            implicitHeight: Math.max(3, Theme.spacing.tiny)
            radius: height / 2
            clip: true
            color: Theme.colors.surfaceVariant
            Rectangle {
                width: parent.width * (root.notification ? root.notification.toast.progress : 0)
                height: parent.height
                radius: parent.radius
                color: Theme.components.notification.urgencyColor(root.notificationUrgency)
            }
        }
    }
}
