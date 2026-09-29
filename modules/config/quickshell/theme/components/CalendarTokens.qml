import QtQuick
import "../colors/runtime"

QtObject {
    id: root

    required property ColorTokens colors

    readonly property real otherMonthOpacity: 0.35

    function dayBackground(today: bool, hovered: bool): color {
        if (today)
            return root.colors.accent;
        if (hovered)
            return root.colors.hoveredSurface;
        return Qt.color("transparent");
    }

    function dayForeground(today: bool): color {
        if (today)
            return root.colors.accentForeground;
        return root.colors.textPrimary;
    }

    function dayOpacity(inCurrentMonth: bool): real {
        return inCurrentMonth ? 1.0 : otherMonthOpacity;
    }
}
