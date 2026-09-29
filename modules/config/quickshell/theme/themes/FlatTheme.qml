import QtQuick
import ".."
import "../colors/presets"
import "../motion/presets"

ThemeDefinition {
    themeId: "flat"
    displayName: "扁平"
    glyph: "󰉈"
    description: "清晰边界 · 简洁层次"
    suggestedPaletteIds: ["catppuccin", "nord"]

    palette: Catppuccin {}
    // Default material, geometry and typography provide the flat style.
    motion: StandardMotion { duration: 150 }
}
