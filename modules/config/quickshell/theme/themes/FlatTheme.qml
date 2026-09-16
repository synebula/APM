import ".."

ThemeDefinition {
    themeId: "flat"
    displayName: "扁平"
    glyph: "󰉈"
    description: "清晰边界 · 简洁层次"
    suggestedPaletteIds: ["catppuccin", "nord"]
    shape: ShapeSpec {
        smallRadius: 4
        controlRadius: 8
        panelRadius: 12
        roundRadius: 26
    }
    border: BorderSpec {
        width: 1
        colorPolicy: "outline"
    }
    elevation: ElevationSpec {
        level: "flat"
        shadowStyle: "none"
        highlightStyle: "none"
    }
    surface: SurfaceSpec {
        mode: "solid"
    }
    spacing: SpacingSpec {
        density: 1
    }
    typography: TypographySpec {}
    motion: MotionSpec {
        duration: 150
    }
}
