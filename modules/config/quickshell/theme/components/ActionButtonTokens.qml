import QtQuick
import "../colors/runtime"
import "../geometry/runtime"
import "../materials/runtime"

QtObject {
    id: root

    required property ColorTokens colors
    required property real controlScale
    required property ShapeTokens shape
    required property SurfaceTokens surface

    readonly property int minHeight: Math.round(32 * root.controlScale)

    function background(enabled: bool, checked: bool, primary: var, tonal: var, destructive: var): color {
        if (!enabled)
            return root.colors.disabledSurface;
        if (destructive && (primary || checked))
            return root.colors.danger;
        if (destructive && tonal)
            return root.colors.dangerContainer;
        if (primary || checked)
            return root.colors.accent;
        if (tonal)
            return root.colors.accentContainer;
        return Qt.color("transparent");
    }

    function foreground(enabled: bool, checked: bool, primary: var, tonal: var, destructive: var): color {
        if (!enabled)
            return root.colors.disabledText;
        if (destructive && (primary || checked))
            return root.colors.dangerForeground;
        if (primary || checked)
            return root.colors.accentForeground;
        if (destructive)
            return root.colors.danger;
        if (tonal)
            return root.colors.accent;
        return root.colors.textPrimary;
    }

    function borderColor(visualFocus: bool, checked: bool, destructive: var): color {
        if (visualFocus)
            return destructive ? root.colors.danger : root.colors.focusRing;
        if (checked)
            return destructive ? root.colors.danger : root.colors.accent;
        return Qt.color("transparent");
    }

    function borderWidth(visualFocus: bool, checked: bool, isSurface: bool): int {
        if (isSurface)
            return root.surface.borderWidth;
        if (visualFocus || checked)
            return root.shape.borderWidth;
        return 0;
    }
}
