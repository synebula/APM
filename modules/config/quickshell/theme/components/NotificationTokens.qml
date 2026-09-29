import QtQuick
import "../colors/runtime"
import "../materials/runtime"
import "../colors/runtime/ColorMath.js" as ColorMath

QtObject {
    id: root

    required property ColorTokens colors
    required property real controlScale
    required property bool isDark
    required property SurfaceTokens surface

    function cardColor(toastMode: bool): color {
        if (toastMode)
            return root.colors.surface;
        return ColorMath.blend(root.colors.surface, root.colors.surfaceVariant, 0.24);
    }

    function indicatorTone(dnd: bool, unread: bool): color {
        if (dnd)
            return root.colors.danger;
        if (unread)
            return root.colors.accent;
        return root.colors.textPrimary;
    }

    function centerStatusTone(dnd: bool, hasRecords: bool): color {
        if (dnd)
            return root.colors.warning;
        if (hasRecords)
            return root.colors.accent;
        return root.colors.textPrimary;
    }

    function urgencyColor(urgency: int): color {
        return urgency === 2 ? root.colors.danger : root.colors.accent;
    }

    function cardBackground(toastMode: bool, unread: bool, hovered: bool, urgency: int): color {
        let baseColor;
        if (toastMode) {
            baseColor = root.surface.isGlass
                ? root.surface.fill
                : ColorMath.blend(root.colors.surface, root.colors.surfaceVariant, 0.45);
        } else {
            if (urgency === 2) {
                baseColor = ColorMath.blend(root.colors.surface, root.colors.danger, 0.12);
            } else if (unread) {
                const variantSurface = ColorMath.blend(root.colors.surface, root.colors.surfaceVariant, 0.55);
                baseColor = ColorMath.blend(variantSurface, root.colors.accent, 0.08);
            } else {
                baseColor = ColorMath.blend(root.colors.surface, root.colors.surfaceVariant, 0.55);
            }
        }

        if (hovered)
            return ColorMath.blend(baseColor, root.colors.accent, 0.10);
        return baseColor;
    }

    function cardBorderColor(toastMode: bool, unread: bool, hovered: bool, urgency: int): color {
        if (urgency === 2)
            return ColorMath.alpha(root.colors.danger, hovered ? 0.85 : 0.60);
        if (toastMode)
            return hovered ? root.colors.accent : ColorMath.blend(root.colors.outline, root.colors.accent, 0.35);
        if (unread)
            return hovered ? root.colors.accent : ColorMath.alpha(root.colors.accent, 0.45);
        return hovered ? ColorMath.alpha(root.colors.accent, 0.50) : ColorMath.alpha(root.colors.outline, 0.70);
    }

    function appNameColor(urgency: int): color {
        return urgencyColor(urgency);
    }

    function iconContainerColor(urgency: int): color {
        return urgency === 2 ? root.colors.dangerContainer : root.colors.accentContainer;
    }

    function iconGlyphColor(urgency: int): color {
        return urgencyColor(urgency);
    }

    function accentStripColor(unread: bool, urgency: int): color {
        if (urgency === 2)
            return root.colors.danger;
        if (unread)
            return root.colors.accent;
        return ColorMath.alpha(root.colors.textSecondary, 0.35);
    }

    function emptyBadgeColor(dnd: bool): color {
        return ColorMath.alpha(dnd ? root.colors.warning : root.colors.accent, 0.12);
    }

    readonly property color listBackground: ColorMath.alpha(root.colors.background, root.isDark ? 0.35 : 0.25)
    readonly property int cardWidth: Math.round(420 * root.controlScale)
    readonly property int overflowBadgeHeight: Math.round(26 * root.controlScale)
}
