import "../../theme"
import "../controllers"
import "../controls"
import "../effects"
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland

ModalWindow {
    id: root

    readonly property var request: ConfirmationController.request

    isOpen: ConfirmationController.isOpen
    onCloseRequested: ConfirmationController.cancel()
    WlrLayershell.namespace: "quickshell-confirm"

    SurfaceFrame {
        id: card

        anchors.centerIn: parent
        width: Math.min(parent.width - Theme.spacing.section * 2, 360 * Theme.controlScale)
        height: content.implicitHeight + Theme.spacing.section * 2
        radius: Theme.shape.panelRadius
        fill: Theme.components.surface.fill

        CompositorBlurRegion {
            targetWindow: root
            backgroundItem: card
            radius: card.radius
        }

        // Consume clicks in the card while allowing child controls to handle their own events.
        MouseArea {
            anchors.fill: parent
        }
    }

    Item {
        anchors.fill: card

        ColumnLayout {
            id: content

            anchors.fill: parent
            anchors.margins: Theme.spacing.section
            spacing: Theme.spacing.extraLarge
            Keys.onReturnPressed: ConfirmationController.confirm()
            Keys.onEnterPressed: ConfirmationController.confirm()
            focus: root.isOpen

            IconGlyph {
                text: root.request.glyph || ""
                color: Theme.components.status.tone(root.request.destructive)
                font.pixelSize: Theme.typography.headingSize
                Layout.alignment: Qt.AlignHCenter
            }

            TextLabel {
                text: root.request.title || ""
                font: Theme.typography.title
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            TextLabel {
                text: root.request.message || ""
                wrapMode: Text.Wrap
                color: Theme.colors.textSecondary
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.large

                ActionButton {
                    text: (root.request.cancelText || "取消") + " (Esc)"
                    Layout.fillWidth: true
                    onClicked: ConfirmationController.cancel()
                }

                ActionButton {
                    text: (root.request.confirmText || "确定") + " (Enter)"
                    primary: true
                    destructive: root.request.destructive
                    Layout.fillWidth: true
                    onClicked: ConfirmationController.confirm()
                }
            }
        }
    }
}
