import QtQuick

QtObject {
    required property string themeId
    required property string displayName
    required property string glyph
    required property string description
    property list<string> recommendedPaletteIds: []

    property ShapeSpec shape: ShapeSpec {}
    property BorderSpec border: BorderSpec {}
    property ElevationSpec elevation: ElevationSpec {}
    property SurfaceSpec surface: SurfaceSpec {}
    property SpacingSpec spacing: SpacingSpec {}
    property TypographySpec typography: TypographySpec {}
    property MotionSpec motion: MotionSpec {}
}
