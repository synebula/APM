import QtQuick
import "../colors/runtime"
import "../geometry/runtime"

QtObject {
    id: root

    required property ColorTokens colors
    required property real controlScale
    required property ShapeTokens shape
    required property real spacingScale

    readonly property int minHeight: Math.round(32 * root.controlScale)
    readonly property int padding: Math.round(10 * root.spacingScale)

    function background(enabled: bool, selected: bool, destructive: var): color {
        if (selected)
            return destructive ? root.colors.dangerContainer : root.colors.selectedSurface;
        return Qt.color("transparent");
    }

    function foreground(enabled: bool, selected: bool, destructive: bool): color {
        if (!enabled)
            return root.colors.disabledText;
        if (destructive)
            return root.colors.danger;
        if (selected)
            return root.colors.accent;
        return root.colors.textPrimary;
    }

    function borderColor(visualFocus: bool, selected: bool, destructive: var): color {
        if (visualFocus || selected)
            return destructive ? root.colors.danger : (visualFocus ? root.colors.focusRing : root.colors.accent);
        return Qt.color("transparent");
    }

    function borderWidth(visualFocus: bool, selected: bool): int {
        return (visualFocus || selected) ? root.shape.borderWidth : 0;
    }
}
