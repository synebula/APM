import ".."

ThemeDefinition {
    themeId: "neumorphic"
    displayName: "仿真"
    glyph: "󰆾"
    description: "柔和阴影 · 立体表面"
    recommendedPaletteIds: ["pastel-relief", "catppuccin"]
    shape: ShapeSpec {
        smallRadius: 4
        controlRadius: 8
        panelRadius: 12
        roundRadius: 26
    }
    border: BorderSpec {
        width: 0
        colorPolicy: "transparent"
    }
    elevation: ElevationSpec {
        level: "elevated"
        shadowStyle: "soft"
        shadowBlur: 0.65
        shadowHorizontalOffset: 2
        shadowVerticalOffset: 3
        shadowOpacity: 0.20
        shadowColorPolicy: "foreground"
        highlightStyle: "top"
        highlightOpacity: 0.20
    }
    surface: SurfaceSpec {
        mode: "gradient"
        gradientLighten: 1.018
        gradientDarken: 1.018
    }
    spacing: SpacingSpec {
        density: 1.05
    }
    typography: TypographySpec {}
    motion: MotionSpec {
        duration: 220
    }
}
