pragma Singleton
import QtQuick
import Quickshell
import "../config"
import "appearance"
import "themes"
import "colors"
import "colors/runtime"
import "geometry/runtime"
import "materials/runtime"
import "typography/runtime"
import "motion"
import "motion/runtime"
import "components"

Singleton {
    id: root

    readonly property ThemeDefinition definition: ThemeCatalog.find(AppearanceSettings.themeId) || ThemeCatalog.defaultTheme
    readonly property bool paletteFollowsTheme: PaletteCatalog.find(AppearanceSettings.paletteId) === null
    readonly property PaletteDefinition palette: PaletteCatalog.find(AppearanceSettings.paletteId) || root.definition.palette
    readonly property bool motionFollowsTheme: MotionCatalog.find(AppearanceSettings.motionId) === null
    readonly property MotionProfile motionProfile: MotionCatalog.find(AppearanceSettings.motionId) || root.definition.motion
    readonly property string colorMode: ["system", "light", "dark"].includes(AppearanceSettings.colorMode) ? AppearanceSettings.colorMode : "system"
    readonly property string resolvedColorMode: root.colorMode === "system" ? ColorModeResolver.systemMode : root.colorMode
    readonly property bool isDark: root.resolvedColorMode === "dark"
    readonly property PaletteVariant paletteVariant: root.palette.variant(root.resolvedColorMode) || root.palette.defaultVariant
    readonly property string displayName: root.definition.displayName
    readonly property string accentId: root.colors.accentId
    readonly property bool accentCustomized: root.accentId !== root.paletteVariant.defaultAccentId
    readonly property real fontScale: Math.max(0.75, Math.min(2, AppearanceSettings.fontScale))
    readonly property real spacingScale: Math.max(0.5, Math.min(2, AppearanceSettings.spacingScale))
    readonly property real controlScale: Math.max(root.fontScale, root.spacingScale)
    readonly property real disabledOpacity: 0.45

    readonly property ColorTokens colors: ColorTokens {
        variant: root.paletteVariant
        requestedAccentId: AppearanceSettings.accentId
        isDark: root.isDark
    }

    readonly property ShapeTokens shape: ShapeTokens {
        spec: root.definition.geometry.shape
        radiusScale: AppearanceSettings.radiusScale
    }

    readonly property SpacingTokens spacing: SpacingTokens {
        spec: root.definition.geometry.spacing
        spacingScale: root.spacingScale
    }

    readonly property TypographyTokens typography: TypographyTokens {
        spec: root.definition.typography
        fontFamily: AppearanceSettings.fontFamily
        iconFamily: AppearanceSettings.iconFontFamily
        fontScale: root.fontScale
    }

    readonly property MotionTokens motion: MotionTokens {
        spec: root.motionProfile
        scale: Math.max(0, Math.min(4, AppearanceSettings.motionScale))
    }

    readonly property SurfaceTokens surface: SurfaceTokens {
        spec: root.definition.material
        colors: root.colors
        isDark: root.isDark
        controlScale: root.controlScale
    }

    readonly property ComponentTokens components: ComponentTokens {
        colors: root.colors
        shape: root.shape
        spacing: root.spacing
        _surface: root.surface
        isDark: root.isDark
        controlScale: root.controlScale
        fontScale: root.fontScale
        spacingScale: root.spacingScale
    }
}
