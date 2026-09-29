import "../../theme"
import "../../theme/components"
import "../effects"
import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T

T.ItemDelegate {
    id: root

    readonly property ActionRowTokens _tokens: Theme.components.actionRow

    property string glyph: ""
    property string description: ""
    property string trailingText: ""
    property bool selected: false
    property bool destructive: false
    property color foreground: root._tokens.foreground(root.enabled, root.selected, root.destructive)
    property int iconSize: Theme.components.iconButton.iconSize
    default property alias trailingContent: trailing.data

    font: Theme.typography.body
    hoverEnabled: true
    padding: Theme.spacing.small
    leftPadding: root._tokens.padding
    rightPadding: leftPadding
    spacing: Theme.spacing.medium
    implicitHeight: Math.max(root._tokens.minHeight, implicitContentHeight + topPadding + bottomPadding)
    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    opacity: enabled ? 1 : Theme.disabledOpacity

    background: Rectangle {
        color: root._tokens.background(root.enabled, root.selected, root.destructive)
        radius: Theme.shape.controlRadius
        border.width: root._tokens.borderWidth(root.visualFocus, root.selected)
        border.color: root._tokens.borderColor(root.visualFocus, root.selected, root.destructive)

        StateLayer {
            anchors.fill: parent
            layerRadius: Theme.shape.controlRadius
            hovered: root.hovered
            focused: root.visualFocus
            pressed: root.down
            color: root.foreground
        }
    }

    contentItem: RowLayout {
        spacing: root.spacing

        IconView {
            id: leadingImage

            visible: root.icon.name.length > 0 || root.icon.source.toString().length > 0
            source: root.icon.name || root.icon.source.toString()
            fallbackGlyph: root.glyph || "󰈙"
            foreground: root.foreground
            Layout.preferredWidth: root.iconSize
            Layout.preferredHeight: root.iconSize
            Layout.alignment: Qt.AlignVCenter
        }

        IconGlyph {
            visible: root.glyph.length > 0 && !leadingImage.visible
            text: root.glyph
            color: root.foreground
            font.pixelSize: root.iconSize
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.tiny

            TextLabel {
                objectName: "actionRowTitle"
                text: root.text
                font: root.selected ? Theme.typography.withOverrides(root.font, { weight: Theme.typography.title.weight }) : root.font
                color: root.foreground
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            TextLabel {
                visible: root.description.length > 0
                text: root.description
                font: Theme.typography.caption
                color: Theme.colors.textSecondary
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        TextLabel {
            visible: root.trailingText.length > 0
            text: root.trailingText
            font: Theme.typography.caption
            color: Theme.colors.textSecondary
        }

        Row {
            id: trailing

            spacing: Theme.spacing.small
            Layout.alignment: Qt.AlignVCenter
        }
    }
}
