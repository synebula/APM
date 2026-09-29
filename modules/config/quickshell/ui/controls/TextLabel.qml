import "../../theme"
import QtQuick

Text {
    font: Theme.typography.body
    color: enabled ? Theme.colors.textPrimary : Theme.colors.disabledText
    style: Theme.surface.textHaloOpacity > 0 ? Text.Outline : Text.Normal
    styleColor: Theme.surface.textHaloColor
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering
}
