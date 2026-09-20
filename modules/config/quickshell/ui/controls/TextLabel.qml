import "../../theme"
import QtQuick

Text {
    font.family: Theme.typography.family
    font.pixelSize: Theme.typography.bodySize
    color: enabled ? Theme.colors.textPrimary : Theme.colors.disabledText
    style: Theme.components.surface.textHaloOpacity > 0 ? Text.Outline : Text.Normal
    styleColor: Theme.components.surface.textHaloColor
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering
}
