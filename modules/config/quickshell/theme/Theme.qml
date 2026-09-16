pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell

import "../config"
import "./ColorMath.js" as ColorMath

Singleton {
    id: root

    readonly property ThemeDefinition definition: ThemeCatalog.find(AppearanceSettings.themeId) || ThemeCatalog.defaultTheme
    readonly property PaletteDefinition palette: PaletteCatalog.find(AppearanceSettings.paletteId) || PaletteCatalog.defaultPalette
    readonly property string colorMode: ["system", "light", "dark"].includes(AppearanceSettings.colorMode) ? AppearanceSettings.colorMode : "system"
    readonly property string resolvedColorMode: root.colorMode === "system" ? ColorModeResolver.systemMode : root.colorMode
    readonly property PaletteVariant paletteVariant: PaletteCatalog.variant(root.palette.paletteId, root.resolvedColorMode)
    readonly property string displayName: root.definition.displayName
    readonly property string accentId: PaletteCatalog.accentIds(root.paletteVariant).includes(AppearanceSettings.accentId) ? AppearanceSettings.accentId : root.paletteVariant.defaultAccentId
    readonly property bool accentCustomized: root.accentId !== root.paletteVariant.defaultAccentId
    readonly property var userOverrides: AppearanceSettings.userOverrides
    readonly property real fontScale: Math.max(0.75, Math.min(2, AppearanceSettings.fontScale))
    readonly property real spacingScale: Math.max(0.5, Math.min(2, AppearanceSettings.spacingScale))
    readonly property real controlScale: Math.max(root.fontScale, root.spacingScale)

    readonly property ColorTokens colors: ColorTokens {}

    readonly property TypographyTokens typography: TypographyTokens {}

    readonly property SpacingTokens spacing: SpacingTokens {}

    readonly property ShapeTokens shape: ShapeTokens {}

    readonly property MotionTokens motion: MotionTokens {
        baseDuration: root.definition.motion.duration
        scale: Math.max(0, Math.min(4, AppearanceSettings.motionScale))
    }

    readonly property ComponentTokens components: ComponentTokens {}

    component SliderTokens: QtObject {
        readonly property int height: Math.round(20 * root.controlScale)
        readonly property int trackHeight: Math.round(6 * root.spacingScale)
        readonly property int handleSize: Math.round(14 * root.controlScale)
    }

    component PopupTokens: QtObject {
        readonly property int padding: root.spacing.large
        readonly property int gap: root.spacing.small
    }

    component IconButtonTokens: QtObject {
        readonly property int size: Math.round(28 * root.controlScale)
        readonly property int compactSize: Math.round(22 * root.controlScale)
        readonly property int iconSize: Math.round(14 * root.fontScale)
    }

    component ActionRowTokens: QtObject {
        readonly property int height: Math.round(32 * root.controlScale)
        readonly property int padding: Math.round(10 * root.spacingScale)
    }

    component BarButtonTokens: QtObject {
        readonly property int height: Math.round(22 * root.controlScale)
        readonly property int padding: root.spacing.small
    }

    component BarGroupTokens: QtObject {
        readonly property int height: Math.round(24 * root.controlScale)
        readonly property color background: root.resolvedColorMode === "light" ? root.colors.background : root.colors.surface
        readonly property int padding: Math.round(6 * root.spacingScale)
        readonly property real radius: Math.min(height / 2, 13 * root.shape.scale)
    }

    component BarTokens: QtObject {
        readonly property int height: Math.round(30 * root.controlScale)
        readonly property int inset: Math.round(2 * root.spacingScale)
        readonly property color background: "transparent"
        readonly property color borderColor: "transparent"
        readonly property int padding: Math.round(6 * root.spacingScale)
    }

    component SurfaceTokens: QtObject {
        readonly property color fill: root.colors.surface
        readonly property real fillOpacity: root.definition.surface.fillOpacity
        readonly property string mode: root.definition.surface.mode
        readonly property real blurRadius: root.definition.surface.blurRadius
        readonly property int borderWidth: root.definition.border.width
        readonly property color borderColor: root.borderColor
        readonly property bool shadowEnabled: root.definition.elevation.shadowStyle !== "none"
        readonly property real shadowBlur: root.definition.elevation.shadowBlur
        readonly property real shadowHorizontalOffset: root.definition.elevation.shadowHorizontalOffset
        readonly property real shadowVerticalOffset: root.definition.elevation.shadowVerticalOffset
        readonly property color shadowColor: root.shadowColor
        readonly property bool highlightEnabled: root.definition.elevation.highlightStyle !== "none"
        readonly property color highlightColor: root.highlightColor
        readonly property real gradientLighten: root.definition.surface.gradientLighten
        readonly property real gradientDarken: root.definition.surface.gradientDarken
    }

    component ComponentTokens: QtObject {
        readonly property SurfaceTokens surface: SurfaceTokens {}
        readonly property BarTokens bar: BarTokens {}
        readonly property BarGroupTokens barGroup: BarGroupTokens {}
        readonly property BarButtonTokens barButton: BarButtonTokens {}
        readonly property ActionRowTokens actionRow: ActionRowTokens {}
        readonly property IconButtonTokens iconButton: IconButtonTokens {}
        readonly property PopupTokens popup: PopupTokens {}
        readonly property SliderTokens slider: SliderTokens {}
    }

    component ShapeTokens: QtObject {
        readonly property real scale: Math.max(0, Math.min(3, AppearanceSettings.radiusScale))
        readonly property real smallRadius: root.definition.shape.smallRadius * scale
        readonly property real controlRadius: root.definition.shape.controlRadius * scale
        readonly property real panelRadius: root.definition.shape.panelRadius * scale
        readonly property real roundRadius: root.definition.shape.roundRadius * scale
        readonly property int borderWidth: 1
    }

    component SpacingTokens: QtObject {
        readonly property real density: root.definition.spacing.density
        readonly property int tiny: Math.round(root.definition.spacing.tiny * density * root.spacingScale)
        readonly property int small: Math.round(root.definition.spacing.small * density * root.spacingScale)
        readonly property int medium: Math.round(root.definition.spacing.medium * density * root.spacingScale)
        readonly property int large: Math.round(root.definition.spacing.large * density * root.spacingScale)
        readonly property int extraLarge: Math.round(root.definition.spacing.extraLarge * density * root.spacingScale)
        readonly property int section: Math.round(root.definition.spacing.section * density * root.spacingScale)
    }

    component TypographyTokens: QtObject {
        readonly property string family: root.definition.typography.family || AppearanceSettings.fontFamily
        readonly property string iconFamily: AppearanceSettings.iconFontFamily
        readonly property int bodyWeight: root.definition.typography.bodyWeight
        readonly property int titleWeight: root.definition.typography.titleWeight
        readonly property real letterSpacing: root.definition.typography.letterSpacing
        readonly property int smallSize: Math.round(10 * root.fontScale)
        readonly property int captionSize: Math.round(11 * root.fontScale)
        readonly property int bodySize: Math.round(12 * root.fontScale)
        readonly property int titleSize: Math.round(15 * root.fontScale)
        readonly property int headingSize: Math.round(20 * root.fontScale)
        readonly property font body: Qt.font({
            family: family,
            pixelSize: bodySize,
            weight: bodyWeight,
            letterSpacing: letterSpacing
        })
        readonly property font caption: Qt.font({
            family: family,
            pixelSize: captionSize
        })
        readonly property font title: Qt.font({
            family: family,
            pixelSize: titleSize,
            weight: titleWeight,
            letterSpacing: letterSpacing
        })
    }

    component ColorTokens: QtObject {
        id: palette
        readonly property color background: root.paletteVariant.background
        readonly property color surface: root.paletteVariant.surface
        readonly property color surfaceVariant: root.paletteVariant.surfaceVariant
        readonly property color outline: root.paletteVariant.outline
        readonly property color textPrimary: root.paletteVariant.textPrimary
        readonly property color textSecondary: root.paletteVariant.textSecondary
        readonly property color danger: root.paletteVariant.danger
        readonly property color warning: root.paletteVariant.warning
        readonly property color success: root.paletteVariant.success
        readonly property color info: root.paletteVariant.info
        readonly property color accent: root.paletteVariant.accents[root.accentId]
        readonly property color accentForeground: {
            const result = ColorMath.foreground(palette.accent.r, palette.accent.g, palette.accent.b);
            return result;
        }
        readonly property color dangerForeground: ColorMath.foreground(palette.danger.r, palette.danger.g, palette.danger.b)
        readonly property color hoveredSurface: Qt.rgba(palette.textPrimary.r, palette.textPrimary.g, palette.textPrimary.b, 0.08)
        readonly property color selectedSurface: Qt.rgba(palette.accent.r, palette.accent.g, palette.accent.b, 0.16)
        readonly property color accentContainer: Qt.rgba(palette.accent.r, palette.accent.g, palette.accent.b, 0.15)
        readonly property color dangerContainer: Qt.rgba(palette.danger.r, palette.danger.g, palette.danger.b, 0.15)
        readonly property color scrim: Qt.rgba(0, 0, 0, root.resolvedColorMode === "dark" ? 0.45 : 0.25)
    }

    readonly property color borderColor: {
        const policy = root.definition.border.colorPolicy;
        const source = policy === "surfaceVariant" ? root.colors.surfaceVariant : root.colors.outline;
        if (policy === "transparent")
            return Qt.rgba(0, 0, 0, 0);
        return Qt.rgba(source.r, source.g, source.b, root.definition.border.opacity);
    }

    readonly property color shadowColor: {
        const policy = root.definition.elevation.shadowColorPolicy;
        const source = policy === "foreground" ? root.colors.textPrimary : Qt.rgba(0, 0, 0, 1);
        return Qt.rgba(source.r, source.g, source.b, root.definition.elevation.shadowOpacity);
    }

    readonly property color highlightColor: Qt.rgba(1, 1, 1, root.definition.elevation.highlightOpacity)
}
