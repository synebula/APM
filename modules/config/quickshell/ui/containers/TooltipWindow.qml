import "../../theme"
import "../controllers"
import "../controls"
import "../effects"
import QtQuick
import Quickshell

PopupWindow {
    id: root

    readonly property bool glass: Theme.components.surface.isGlass
    // 玻璃主题下无阴影，卡片铺满表面并使用 panelRadius，
    // 与 niri popups 规则的 geometry-corner-radius 对齐，避免圆角/霜边错位。
    readonly property int edgeInset: root.glass ? 0 : Theme.components.surface.shadowMargin

    anchor.item: TooltipController.activeItem
    anchor.window: TooltipController.activeItem ? TooltipController.activeItem.QsWindow.window : null
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: Theme.spacing.small - root.edgeInset
    visible: TooltipController.visible && anchor.item !== null && anchor.window !== null
    color: "transparent"
    implicitWidth: Math.min(Theme.components.popup.tooltipMaxWidth, text.implicitWidth + Theme.spacing.large * 2) + root.edgeInset * 2
    implicitHeight: text.implicitHeight + Theme.spacing.medium * 2 + root.edgeInset * 2

    SurfaceFrame {
        id: card

        anchors.fill: parent
        anchors.margins: root.edgeInset
        fill: Theme.components.surface.fill
        radius: root.glass ? Theme.shape.panelRadius : Theme.shape.controlRadius

        CompositorBlurRegion {
            targetWindow: root
            backgroundItem: card
            radius: card.radius
        }
    }

    Item {
        anchors.fill: card

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
