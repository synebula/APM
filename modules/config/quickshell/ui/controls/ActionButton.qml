import "../../theme"
import "../controllers"
import "../effects"
import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T

T.Button {
    id: root

    property string glyph: ""
    property string tooltipText: ""
    property bool primary: false
    property bool tonal: false
    property bool destructive: false
    property color foreground: Theme.components.actionButton.foreground(root.enabled, root.checked, root.primary, root.tonal, root.destructive)
    property color fillColor: Theme.components.actionButton.background(root.enabled, root.checked, root.primary, root.tonal, root.destructive)
    property real cornerRadius: Theme.shape.controlRadius
    property int glyphSize: Theme.components.iconButton.iconSize
    property int borderWidth: root.fillColor.a > 0.99 ? Theme.components.surface.borderWidth : (root.visualFocus ? Theme.shape.borderWidth : 0)
    property color borderColor: root.fillColor.a > 0.99 ? Theme.components.surface.borderColor : Theme.components.actionButton.borderColor(root.visualFocus, root.checked, root.destructive)

    font: Theme.typography.body
    padding: Theme.spacing.medium
    spacing: Theme.spacing.medium
    hoverEnabled: true
    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    implicitHeight: Math.max(Theme.components.actionRow.height, implicitContentHeight + topPadding + bottomPadding)
    opacity: enabled ? 1 : 0.4
    onHoveredChanged: {
        if (root.hovered && root.tooltipText)
            TooltipController.show(root, root.tooltipText);
        else
            TooltipController.hide(root);
    }

    Connections {
        function onClicked() {
            TooltipController.hide(root);
        }

        target: root
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

    contentItem: RowLayout {
        spacing: root.spacing

        IconGlyph {
            visible: root.glyph.length > 0
            text: root.glyph
            color: root.foreground
            font.pixelSize: root.glyphSize
            Layout.alignment: Qt.AlignVCenter
        }

        TextLabel {
            visible: root.text.length > 0
            text: root.text
            font: root.font
            color: root.foreground
            elide: Text.ElideRight
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
