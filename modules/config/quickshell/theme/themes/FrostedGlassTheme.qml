import QtQuick
import ".."
import "../colors/presets"
import "../geometry/presets"
import "../materials/presets"
import "../typography/presets"
import "../motion/presets"

ThemeDefinition {
    themeId: "frosted-glass"
    displayName: "磨砂玻璃"
    glyph: "󰤄"
    description: "透光朦胧 · 镜面微边 · 磨砂质感"
    suggestedPaletteIds: ["pastel-relief", "catppuccin", "nord"]

    palette: PastelReliefPalette {}
    material: FrostedGlassMaterial {}
    geometry: RoundedGeometry {}
    typography: SoftTypography {}
    motion: StandardMotion { duration: 320 }
}
