import "../../theme"
import QtQuick

Text {
    font.family: Theme.typography.family
    font.pixelSize: Theme.typography.bodySize
    color: Theme.colors.textPrimary
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering
}
