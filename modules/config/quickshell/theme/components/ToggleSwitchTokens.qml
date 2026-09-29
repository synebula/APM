import QtQuick
import "../colors/runtime"

QtObject {
    id: root

    required property ColorTokens colors

    function trackColor(enabled: bool, checked: bool): color {
        if (!enabled)
            return root.colors.disabledSurface;
        if (checked)
            return root.colors.accent;
        return root.colors.surfaceVariant;
    }

    function knobColor(enabled: bool, checked: bool): color {
        if (!enabled)
            return root.colors.disabledText;
        if (checked)
            return root.colors.accentForeground;
        return root.colors.textSecondary;
    }

    function borderColor(visualFocus: bool): color {
        if (visualFocus)
            return root.colors.focusRing;
        return "transparent";
    }
}
