import QtQuick
import ".."

QtObject {
    id: root

    required property GeometrySpec.Spacing spec
    required property real spacingScale

    readonly property real density: root.spec.density
    readonly property int tiny: Math.round(root.spec.tiny * density * root.spacingScale)
    readonly property int small: Math.round(root.spec.small * density * root.spacingScale)
    readonly property int medium: Math.round(root.spec.medium * density * root.spacingScale)
    readonly property int large: Math.round(root.spec.large * density * root.spacingScale)
    readonly property int extraLarge: Math.round(root.spec.extraLarge * density * root.spacingScale)
    readonly property int section: Math.round(root.spec.section * density * root.spacingScale)
}
