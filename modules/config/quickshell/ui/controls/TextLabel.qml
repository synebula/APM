import "../../theme"
import QtQuick

Text {
    font.family: Theme.typography.family
    font.pixelSize: Theme.typography.bodySize
    color: enabled ? Theme.colors.textPrimary : Theme.colors.disabledText
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering
}
