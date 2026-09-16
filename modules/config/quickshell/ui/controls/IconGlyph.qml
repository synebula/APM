import "../../theme"
import QtQuick

Text {
    font.family: Theme.typography.iconFamily
    font.pixelSize: Theme.components.iconButton.iconSize
    color: Theme.colors.textPrimary
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering
}
