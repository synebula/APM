import QtQuick
import "colors"
import "geometry"
import "materials"
import "typography"
import "motion"

QtObject {
    id: root
    required property string themeId
    required property string displayName
    required property string glyph
    required property string description
    // 建议配色方案列表（展示与预览搭配建议，不强行耦合运行时）
    property list<string> suggestedPaletteIds: []
    property alias recommendedPaletteIds: root.suggestedPaletteIds
    readonly property string defaultPaletteId: root.palette.paletteId
    required property PaletteDefinition palette

    property MaterialSpec material: MaterialSpec {}
    property GeometrySpec geometry: GeometrySpec {}
    property TypographySpec typography: TypographySpec {}
    property MotionProfile motion: MotionProfile {}
}
