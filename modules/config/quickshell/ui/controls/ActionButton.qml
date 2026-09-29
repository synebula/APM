import "../../theme"
import "../../theme/components"
import "../controllers"
import "../effects"
import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T

T.Button {
    id: root

    readonly property ActionButtonTokens _tokens: Theme.components.actionButton

    property string glyph: ""
    property string tooltipText: ""
    property bool primary: false
    property bool tonal: false
    property bool destructive: false
    // Semantic actions retain their foreground/fill pair; material cards use InteractiveCard.
    property bool materialEnabled: !(root.enabled && (root.primary || root.checked))
    property color foreground: root._tokens.foreground(root.enabled, root.checked, root.primary, root.tonal, root.destructive)
    property color fillColor: root._tokens.background(root.enabled, root.checked, root.primary, root.tonal, root.destructive)
    property real cornerRadius: Theme.shape.controlRadius
    property int glyphSize: Theme.components.iconButton.iconSize
    property int borderWidth: root._tokens.borderWidth(root.visualFocus, root.checked, root.fillColor.a > 0.99)
    property color borderColor: root.fillColor.a > 0.99 ? Theme.surface.borderColor : root._tokens.borderColor(root.visualFocus, root.checked, root.destructive)

    font: Theme.typography.body
    padding: Theme.spacing.medium
    spacing: Theme.spacing.medium
    hoverEnabled: true
    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    implicitHeight: Math.max(root._tokens.minHeight, implicitContentHeight + topPadding + bottomPadding)
    opacity: enabled ? 1 : Theme.disabledOpacity
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
        materialEnabled: root.materialEnabled
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
