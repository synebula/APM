import QtQuick

QtObject {
    id: root
    required property string themeId
    required property string displayName
    required property string glyph
    required property string description
    // 建议配色方案列表（展示与预览搭配建议，不强行耦合运行时）
    property list<string> suggestedPaletteIds: []
    property alias recommendedPaletteIds: root.suggestedPaletteIds
    readonly property string defaultPaletteId: root.suggestedPaletteIds.length > 0 ? root.suggestedPaletteIds[0] : "pastel-relief"

    property ShapeSpec shape: ShapeSpec {}
    property BorderSpec border: BorderSpec {}
    property ElevationSpec elevation: ElevationSpec {}
    property SurfaceSpec surface: SurfaceSpec {}
    property SpacingSpec spacing: SpacingSpec {}
    property TypographySpec typography: TypographySpec {}
    property MotionSpec motion: MotionSpec {}
}
