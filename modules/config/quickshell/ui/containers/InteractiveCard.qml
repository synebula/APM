import QtQuick
import QtQuick.Templates as T
import "../../theme"
import "../controllers"
import "../effects"

T.AbstractButton {
    id: root

    property string tooltipText: ""
    property color foreground: Theme.colors.textPrimary
    property color fillColor: Theme.surface.fill
    property real cornerRadius: Theme.shape.controlRadius
    property int borderWidth: Theme.surface.borderWidth
    property color borderColor: Theme.surface.borderColor

    font: Theme.typography.body
    padding: Theme.spacing.medium
    spacing: Theme.spacing.medium
    hoverEnabled: true
    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    implicitHeight: implicitContentHeight + topPadding + bottomPadding
    opacity: enabled ? 1 : Theme.disabledOpacity
    onHoveredChanged: {
        if (root.hovered && root.tooltipText)
            TooltipController.show(root, root.tooltipText);
        else
            TooltipController.hide(root);
    }
    Connections {
        target: root
        function onClicked() { TooltipController.hide(root); }
    }

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
}
