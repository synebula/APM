import QtQuick
import "../colors/runtime"

QtObject {
    id: root

    required property ColorTokens colors

    function tone(urgent: bool): color {
        return urgent ? root.colors.danger : root.colors.accent;
    }

    function foreground(urgent: bool): color {
        return urgent ? root.colors.dangerForeground : root.colors.accentForeground;
    }

    function text(urgent: bool): color {
        return urgent ? root.colors.danger : root.colors.textPrimary;
    }
}
