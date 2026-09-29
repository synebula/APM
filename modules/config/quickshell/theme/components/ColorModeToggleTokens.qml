import QtQuick
import "../colors/runtime"

QtObject {
    id: root

    required property ColorTokens colors

    readonly property real inactiveIconOpacity: 0.65

    function trackColor(checked: bool): color {
        return checked ? Qt.rgba(root.colors.accent.r, root.colors.accent.g, root.colors.accent.b, 0.2) : root.colors.surfaceVariant;
    }

    function trackBorder(checked: bool): color {
        return checked ? root.colors.accent : root.colors.outline;
    }

    function knobColor(checked: bool): color {
        return checked ? root.colors.accent : root.colors.background;
    }

    function knobBorder(checked: bool): color {
        return checked ? root.colors.accent : root.colors.outline;
    }

    function knobForeground(checked: bool): color {
        return checked ? root.colors.accentForeground : root.colors.accent;
    }

    function iconColor(active: bool): color {
        return active ? root.colors.accent : root.colors.textSecondary;
    }
}
