import "../../theme"
import "../effects"
import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T

T.ItemDelegate {
    id: root

    property string glyph: ""
    property string description: ""
    property string trailingText: ""
    property bool selected: false
    property bool destructive: false
    property color foreground: Theme.components.actionRow.foreground(root.enabled, root.selected, root.destructive)
    property int iconSize: Theme.components.iconButton.iconSize
    default property alias trailingContent: trailing.data

    font: Theme.typography.body
    hoverEnabled: true
    padding: Theme.spacing.small
    leftPadding: Theme.components.actionRow.padding
    rightPadding: leftPadding
    spacing: Theme.spacing.medium
    implicitHeight: Math.max(Theme.components.actionRow.height, implicitContentHeight + topPadding + bottomPadding)
    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    opacity: enabled ? 1 : Theme.disabledOpacity

    background: Rectangle {
        color: Theme.components.actionRow.background(root.enabled, root.selected, root.destructive)
        radius: Theme.shape.controlRadius
        border.width: Theme.components.actionRow.borderWidth(root.visualFocus, root.selected)
        border.color: Theme.components.actionRow.borderColor(root.visualFocus, root.selected, root.destructive)

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
                text: root.text
                font: root.selected ? Qt.font({
                    "family": root.font.family,
                    "pixelSize": root.font.pixelSize,
                    "bold": true
                }) : root.font
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
