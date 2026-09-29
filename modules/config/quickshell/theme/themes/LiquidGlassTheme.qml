import QtQuick
import ".."
import "../colors/presets"
import "../geometry/presets"
import "../materials/presets"
import "../typography/presets"
import "../motion/presets"

ThemeDefinition {
    themeId: "liquid-glass"
    displayName: "液态玻璃"
    glyph: "󰤄"
    description: "清澈流体 · 菲涅尔曲光 · 灵动立面"
    suggestedPaletteIds: ["pastel-relief", "catppuccin", "nord"]

    palette: PastelReliefPalette {}
    material: LiquidGlassMaterial {}
    geometry: LargeRoundedGeometry {}
    typography: SoftTypography {}
    motion: StandardMotion { duration: 360 }
}
