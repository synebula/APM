import QtQuick
import "../colors/runtime"
import "../geometry/runtime"

QtObject {
    id: root

    required property ColorTokens colors
    required property real controlScale
    required property SpacingTokens spacing

    readonly property int height: Math.round(22 * root.controlScale)
    readonly property int padding: root.spacing.small

    function background(active: bool, urgent: bool): color {
        if (active)
            return root.colors.accent;
        if (urgent)
            return root.colors.danger;
        return "transparent";
    }

    function foreground(active: bool, urgent: bool): color {
        if (active)
            return root.colors.accentForeground;
        if (urgent)
            return root.colors.dangerForeground;
        return root.colors.textPrimary;
    }
}
