import QtQuick
import ".."
import "ColorMath.js" as ColorMath

QtObject {
    id: root

    required property PaletteVariant variant
    required property string requestedAccentId
    required property bool isDark

    readonly property string accentId: Object.keys(root.variant.accents).includes(root.requestedAccentId)
        ? root.requestedAccentId : root.variant.defaultAccentId

    readonly property color background: root.variant.background
    readonly property color surface: root.variant.surface
    readonly property color surfaceVariant: root.variant.surfaceVariant
    readonly property color outline: root.variant.outline
    readonly property color textPrimary: root.variant.textPrimary
    readonly property color textSecondary: root.variant.textSecondary
    readonly property color danger: root.variant.danger
    readonly property color warning: root.variant.warning
    readonly property color success: root.variant.success
    readonly property color info: root.variant.info
    readonly property color accent: root.variant.accents[root.accentId]
    readonly property color accentForeground: ColorMath.foreground(accent.r, accent.g, accent.b)
    readonly property color dangerForeground: ColorMath.foreground(danger.r, danger.g, danger.b)
    readonly property color disabledText: ColorMath.alpha(textSecondary, 0.45)
    readonly property color disabledSurface: ColorMath.alpha(surfaceVariant, 0.5)
    readonly property color focusRing: ColorMath.alpha(accent, 0.5)
    readonly property color hoveredSurface: ColorMath.blend(surface, textPrimary, 0.08)
    readonly property color selectedSurface: ColorMath.blend(surface, accent, 0.16)
    readonly property color accentContainer: ColorMath.alpha(accent, 0.15)
    readonly property color dangerContainer: ColorMath.alpha(danger, 0.15)
    readonly property color scrim: Qt.rgba(0, 0, 0, root.isDark ? 0.45 : 0.25)
}
