pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell

import "../../theme"
import "../../ui/controls"
import "../../ui/effects"

ActionButton {
    id: root
    required property NotificationRecord notification
    property bool toastMode: false
    // toast 模式下向宿主窗口登记自身，供其模糊区域槽位引用
    property var toastWindow: null
    signal dismissRequested
    signal actionRequested(string actionId)

    readonly property bool isUrgent: root.notification && root.notification.urgency === 2
    readonly property bool isUnread: root.notification && root.notification.unread
    readonly property int notificationUrgency: root.notification ? root.notification.urgency : 1
    readonly property bool hasAppIcon: !!(root.notification && root.notification.appIcon && root.notification.appIcon.length > 0)
    readonly property bool hasImage: !!(root.notification && root.notification.image && root.notification.image.length > 0)
    readonly property string resolvedImage: {
        if (!root.hasImage)
            return "";
        const img = root.notification.image;
        if (img.startsWith("/"))
            return "file://" + img;
        if (img.startsWith("image://icon/")) {
            const sub = img.slice(13);
            if (sub.startsWith("/"))
                return "file://" + sub;
            return Quickshell.iconPath(sub, true) || img;
        }
        if (img.includes("://"))
            return img;
        return Quickshell.iconPath(img, true) || img;
    }

    topPadding: Theme.spacing.large
    bottomPadding: Theme.spacing.large
    leftPadding: Theme.spacing.large + Math.round(6 * Theme.controlScale)
    rightPadding: Theme.spacing.large

    fillColor: Theme.components.notification.cardBackground(root.toastMode, root.isUnread, root.hovered, root.notificationUrgency)
    borderWidth: Theme.components.surface.borderWidth
    borderColor: Theme.components.notification.cardBorderColor(root.toastMode, root.isUnread, root.hovered, root.notificationUrgency)
    foreground: Theme.components.notification.appNameColor(root.notificationUrgency)
    cornerRadius: Theme.shape.controlRadius
    implicitHeight: implicitContentHeight + topPadding + bottomPadding

    background: SurfaceFrame {
        fill: root.fillColor
        radius: root.cornerRadius
        borderWidth: root.borderWidth
        borderColor: root.borderColor

        StateLayer {
            anchors.fill: parent
            layerRadius: root.cornerRadius
            color: root.foreground
            hovered: root.hovered
            focused: root.visualFocus
            pressed: root.down
        }
    }

    HoverHandler {
        onHoveredChanged: {
            if (root.toastMode && root.notification)
                root.notification.toast.setPaused(root, hovered);
        }
    }
    Component.onCompleted: {
        if (root.toastMode && root.toastWindow)
            root.toastWindow.registerToastCard(root);
    }
    Component.onDestruction: {
        if (root.notification)
            root.notification.toast.setPaused(root, false);
        if (root.toastMode && root.toastWindow)
            root.toastWindow.unregisterToastCard(root);
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
                    source: root.hasAppIcon ? root.notification.appIcon : root.resolvedImage
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
                        implicitWidth: Math.round(6 * Theme.controlScale)
                        implicitHeight: implicitWidth
                        radius: implicitWidth / 2
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

        Item {
            id: imageArea
            visible: root.hasImage && previewImage.status === Image.Ready && (root.hasAppIcon || previewImage.implicitWidth > 128)
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? displayHeight : 0

            readonly property real maxWidth: width > 0 ? width : (360 * Theme.controlScale)
            readonly property real maxHeight: (root.toastMode ? 160 : 180) * Theme.controlScale

            readonly property real scaleFactor: {
                if (previewImage.implicitWidth <= 0 || previewImage.implicitHeight <= 0)
                    return 1.0;
                const sW = previewImage.implicitWidth > maxWidth ? (maxWidth / previewImage.implicitWidth) : 1.0;
                const sH = previewImage.implicitHeight > maxHeight ? (maxHeight / previewImage.implicitHeight) : 1.0;
                return Math.min(sW, sH);
            }

            readonly property real displayWidth: Math.round(previewImage.implicitWidth * scaleFactor)
            readonly property real displayHeight: Math.round(previewImage.implicitHeight * scaleFactor)

            Rectangle {
                width: imageArea.displayWidth
                height: imageArea.displayHeight
                radius: Theme.shape.controlRadius
                color: Theme.colors.surfaceVariant
                border.width: 1
                border.color: Theme.colors.outline
                clip: true

                Image {
                    id: previewImage
                    anchors.fill: parent
                    source: root.resolvedImage
                    fillMode: Image.PreserveAspectFit
                    asynchronous: true
                    mipmap: true
                }
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
