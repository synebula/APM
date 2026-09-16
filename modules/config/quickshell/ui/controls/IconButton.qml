import "../../theme"
import QtQuick

ActionButton {
    id: root

    property bool compact: false

    implicitWidth: compact ? Theme.components.iconButton.compactSize : Theme.components.iconButton.size
    implicitHeight: implicitWidth
    padding: Theme.spacing.small
    Accessible.name: tooltipText

    contentItem: IconGlyph {
        text: root.glyph
        color: root.foreground
        font.pixelSize: root.glyphSize
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
}
