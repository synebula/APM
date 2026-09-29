import "../../theme"
import QtQuick

Text {
    font.family: Theme.typography.iconFamily
    font.pixelSize: Theme.components.iconButton.iconSize
    color: Theme.colors.textPrimary
    style: Theme.surface.textHaloOpacity > 0 ? Text.Outline : Text.Normal
    styleColor: Theme.surface.textHaloColor
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering
}
