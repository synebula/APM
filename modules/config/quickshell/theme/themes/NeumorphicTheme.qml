import QtQuick
import ".."
import "../colors/presets"
import "../materials/presets"
import "../motion/presets"

ThemeDefinition {
    themeId: "neumorphic"
    displayName: "新拟物"
    glyph: "󰆾"
    description: "柔和阴影 · 立体表面"
    suggestedPaletteIds: ["pastel-relief", "catppuccin"]

    palette: PastelReliefPalette {}
    material: NeumorphicMaterial {}
    geometry.spacing.density: 1.05
    motion: StandardMotion {}
}
