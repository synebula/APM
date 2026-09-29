import QtQuick
import "../colors/runtime"

QtObject {
    id: root

    required property ColorTokens colors

    function background(checked: bool): color {
        return checked ? root.colors.selectedSurface : Qt.color("transparent");
    }

    function borderColor(checked: bool, visualFocus: bool): color {
        return (checked || visualFocus) ? root.colors.accent : root.colors.outline;
    }

    function borderWidth(checked: bool, visualFocus: bool): int {
        return (checked || visualFocus) ? 2 : 1;
    }

    function accentColor(checked: bool): color {
        return checked ? root.colors.accent : root.colors.textSecondary;
    }
}
