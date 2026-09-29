import QtQuick
import "../colors/runtime"
import "../geometry/runtime"
import "../materials/runtime"

QtObject {
    id: root

    required property ColorTokens colors
    required property real controlScale
    required property SpacingTokens spacing
    required property SurfaceTokens surface

    readonly property color background: root.surface.fill
    readonly property int padding: root.spacing.large
    readonly property int gap: root.spacing.small
    readonly property int tooltipMaxWidth: Math.round(480 * root.controlScale)

    function swatchBorderColor(selected: bool, visualFocus: bool): color {
        return (selected || visualFocus) ? root.colors.textPrimary : root.colors.outline;
    }

    function swatchBorderWidth(selected: bool, visualFocus: bool): int {
        return (selected || visualFocus) ? 2 : 1;
    }
}
