pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import Quickshell.Wayland

import "../../services"
import "../../theme"
import "../../ui/containers"
import "../../ui/controls"
import "../../ui/effects"

ModalWindow {
    id: root

    property bool showPlaintext: false
    property real shakeOffset: 0

    isOpen: PolkitService.isOpen
    onCloseRequested: PolkitService.cancel()
    WlrLayershell.namespace: "quickshell-polkit"

    function submit() {
        if (!PolkitService.isSubmitting && (passwordInput.text.length > 0 || !PolkitService.isResponseRequired)) {
            PolkitService.submit(passwordInput.text);
        }
    }

    onIsOpenChanged: {
        if (root.isOpen) {
            root.showPlaintext = false;
            root.shakeOffset = 0;
            passwordInput.text = "";
            passwordInput.forceActiveFocus();
        }
    }

    SequentialAnimation {
        id: shakeAnim

        NumberAnimation {
            target: root
            property: "shakeOffset"
            from: 0
            to: -12
            duration: 45
            easing.type: Easing.OutQuad
        }

        NumberAnimation {
            target: root
            property: "shakeOffset"
            from: -12
            to: 12
            duration: 45
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: root
            property: "shakeOffset"
            from: 12
            to: -8
            duration: 45
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: root
            property: "shakeOffset"
            from: -8
            to: 8
            duration: 45
            easing.type: Easing.InOutQuad
        }

        NumberAnimation {
            target: root
            property: "shakeOffset"
            from: 8
            to: 0
            duration: 45
            easing.type: Easing.OutQuad
        }
    }

    Connections {
        target: PolkitService

        function onErrorTriggered() {
            shakeAnim.restart();
            passwordInput.selectAll();
            passwordInput.forceActiveFocus();
        }
    }

    SurfaceFrame {
        id: card

        anchors.centerIn: parent
        anchors.horizontalCenterOffset: root.shakeOffset
        width: Math.min(parent.width - Theme.spacing.section * 2, 440 * Theme.controlScale)
        height: contentLayout.implicitHeight + Theme.spacing.section * 2
        radius: Theme.shape.panelRadius
        fill: Theme.components.surface.fill
        borderWidth: Theme.components.surface.borderWidth
        borderColor: Theme.components.surface.borderColor

        CompositorBlurRegion {
            targetWindow: root
            backgroundItem: card
            radius: card.radius
        }

        MouseArea {
            anchors.fill: parent
        }
    }

    Item {
        anchors.fill: card

        ColumnLayout {
            id: contentLayout

            anchors.fill: parent
            anchors.margins: Theme.spacing.section
            spacing: Theme.spacing.large

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.large

                Rectangle {
                    Layout.preferredWidth: 44 * Theme.controlScale
                    Layout.preferredHeight: 44 * Theme.controlScale
                    radius: Theme.shape.controlRadius
                    color: Theme.colors.accentContainer

                    IconGlyph {
                        anchors.centerIn: parent
                        text: "󰌾"
                        font.pixelSize: Theme.typography.headingSize
                        color: Theme.colors.accent
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.tiny

                    TextLabel {
                        text: "系统提权认证"
                        font: Theme.typography.title
                        color: Theme.colors.textPrimary
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        visible: PolkitService.actionId.length > 0
                        implicitWidth: actionLabel.implicitWidth + Theme.spacing.small * 2
                        implicitHeight: actionLabel.implicitHeight + Theme.spacing.tiny * 2
                        radius: Theme.shape.smallRadius
                        color: Theme.colors.surfaceVariant

                        TextLabel {
                            id: actionLabel

                            anchors.centerIn: parent
                            text: PolkitService.actionId
                            font.pixelSize: Theme.typography.smallSize
                            font.family: Theme.typography.family
                            color: Theme.colors.textSecondary
                            elide: Text.ElideMiddle
                        }
                    }
                }
            }

            TextLabel {
                text: PolkitService.message
                wrapMode: Text.Wrap
                color: Theme.colors.textPrimary
                font: Theme.typography.body
                Layout.fillWidth: true
            }

            ColumnLayout {
                visible: PolkitService.identities.length > 1
                Layout.fillWidth: true
                spacing: Theme.spacing.tiny

                TextLabel {
                    text: "选择认证身份："
                    font: Theme.typography.caption
                    color: Theme.colors.textSecondary
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacing.small

                    Repeater {
                        model: PolkitService.identities

                        ActionButton {
                            required property var modelData

                            readonly property bool isSelected: PolkitService.selectedIdentity
                                && (PolkitService.selectedIdentity.string === modelData.string)

                            text: modelData.displayName || modelData.string
                            glyph: "󰀄"
                            primary: isSelected
                            tonal: !isSelected
                            onClicked: PolkitService.selectIdentity(modelData)
                        }
                    }
                }
            }

            RowLayout {
                visible: PolkitService.identities.length <= 1 && PolkitService.selectedIdentity !== null
                Layout.fillWidth: true
                spacing: Theme.spacing.small

                IconGlyph {
                    text: "󰀄"
                    font.pixelSize: Theme.typography.captionSize
                    color: Theme.colors.textSecondary
                }

                TextLabel {
                    text: "目标用户: " + (PolkitService.selectedIdentity ? (PolkitService.selectedIdentity.displayName || PolkitService.selectedIdentity.string) : "")
                    font: Theme.typography.caption
                    color: Theme.colors.textSecondary
                    Layout.fillWidth: true
                }
            }

            SurfaceFrame {
                id: inputContainer

                Layout.fillWidth: true
                implicitHeight: Math.max(40 * Theme.controlScale, Theme.components.actionRow.height)
                radius: Theme.shape.controlRadius
                fill: Theme.colors.surfaceVariant
                borderWidth: passwordInput.activeFocus ? Theme.shape.focusBorderWidth : Theme.shape.borderWidth
                borderColor: PolkitService.supplementaryIsError ? Theme.colors.danger : (passwordInput.activeFocus ? Theme.colors.focusRing : Theme.colors.outline)

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: Theme.spacing.medium
                    anchors.rightMargin: Theme.spacing.small
                    spacing: Theme.spacing.small

                    IconGlyph {
                        text: "󰌾"
                        font.pixelSize: Theme.typography.bodySize
                        color: passwordInput.activeFocus ? Theme.colors.accent : Theme.colors.textSecondary
                    }

                    T.TextField {
                        id: passwordInput

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        echoMode: (PolkitService.responseVisible || root.showPlaintext) ? TextInput.Normal : TextInput.Password
                        font.family: Theme.typography.family
                        font.pixelSize: Theme.typography.bodySize
                        color: Theme.colors.textPrimary
                        selectionColor: Theme.colors.accent
                        selectedTextColor: Theme.colors.accentForeground
                        placeholderText: PolkitService.inputPrompt ? PolkitService.inputPrompt.replace(/:$/, "").trim() : "请输入密码..."
                        placeholderTextColor: Theme.colors.textSecondary
                        verticalAlignment: TextInput.AlignVCenter
                        selectByMouse: true
                        clip: true
                        enabled: PolkitService.isResponseRequired && !PolkitService.isSubmitting
                        focus: root.isOpen

                        Keys.onReturnPressed: root.submit()
                        Keys.onEnterPressed: root.submit()
                        Keys.onEscapePressed: PolkitService.cancel()
                    }

                    IconButton {
                        visible: !PolkitService.responseVisible
                        glyph: root.showPlaintext ? "󰈈" : "󰈉"
                        tooltipText: root.showPlaintext ? "隐藏密码" : "显示密码"
                        onClicked: root.showPlaintext = !root.showPlaintext
                    }
                }
            }

            RowLayout {
                id: errorRow

                visible: PolkitService.supplementaryMessage.length > 0
                Layout.fillWidth: true
                spacing: Theme.spacing.small

                IconGlyph {
                    text: PolkitService.supplementaryIsError ? "󰅙" : "󰋼"
                    font.pixelSize: Theme.typography.captionSize
                    color: PolkitService.supplementaryIsError ? Theme.colors.danger : Theme.colors.info
                }

                TextLabel {
                    text: PolkitService.supplementaryMessage
                    font: Theme.typography.caption
                    color: PolkitService.supplementaryIsError ? Theme.colors.danger : Theme.colors.textSecondary
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.large

                ActionButton {
                    text: "取消 (Esc)"
                    Layout.fillWidth: true
                    onClicked: PolkitService.cancel()
                }

                ActionButton {
                    text: PolkitService.isSubmitting ? "正在验证..." : "认证 (Enter)"
                    primary: true
                    Layout.fillWidth: true
                    enabled: (passwordInput.text.length > 0 || !PolkitService.isResponseRequired) && !PolkitService.isSubmitting
                    onClicked: root.submit()
                }
            }
        }
    }
}
