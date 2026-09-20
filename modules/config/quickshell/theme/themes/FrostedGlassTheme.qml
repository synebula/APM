import ".."
import QtQuick

ThemeDefinition {
    themeId: "frosted-glass"
    displayName: "磨砂玻璃"
    glyph: "󰤄"
    description: "透光朦胧 · 镜面微边 · 磨砂质感"
    suggestedPaletteIds: ["pastel-relief", "catppuccin", "nord"]

    shape: ShapeSpec {
        smallRadius: 6
        controlRadius: 14
        panelRadius: 20
        roundRadius: 26
    }

    border: BorderSpec {
        width: 1
        opacity: 0.85
        colorPolicy: "outline"
    }

    elevation: ElevationSpec {
        level: "elevated"
        shadowStyle: "soft"
        shadowBlur: 0.82
        shadowHorizontalOffset: 0
        shadowVerticalOffset: 6
        shadowOpacity: 0.18
        shadowColorPolicy: "black"
        highlightStyle: "top"
        highlightOpacity: 0.45
    }

    surface: SurfaceSpec {
        mode: "acrylic"
        fillOpacity: 0.42
        blurRadius: 0
        gradientLighten: 1.02
        gradientDarken: 1.01
    }

    spacing: SpacingSpec {
        density: 1.08
    }

    typography: TypographySpec {
        bodyWeight: Font.Normal
        titleWeight: Font.DemiBold
        letterSpacing: -0.15
    }

    motion: MotionSpec {
        duration: 320
    }
}
