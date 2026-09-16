import "../../theme"
import "../controllers"
import "../controls"
import "../effects"
import QtQuick
import Quickshell

PopupWindow {
    id: root

    anchor.item: TooltipController.activeItem
    anchor.window: TooltipController.activeItem ? TooltipController.activeItem.QsWindow.window : null
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: Theme.spacing.small
    visible: TooltipController.visible && anchor.item !== null && anchor.window !== null
    color: "transparent"
    implicitWidth: Math.min(480 * Theme.controlScale, text.implicitWidth + Theme.spacing.large * 2)
    implicitHeight: text.implicitHeight + Theme.spacing.medium * 2

    SurfaceFrame {
        anchors.fill: parent
        fill: Theme.colors.surface
        radius: Theme.shape.controlRadius

        TextLabel {
            id: text

            width: parent.width - Theme.spacing.large * 2
            anchors.centerIn: parent
            text: TooltipController.text
            wrapMode: Text.Wrap
            font: Theme.typography.caption
        }
    }
}
