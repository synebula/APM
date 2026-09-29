import QtQuick
import ".."

QtObject {
    id: root

    required property GeometrySpec.Shape spec
    required property real radiusScale

    readonly property real scale: Math.max(0, Math.min(3, root.radiusScale))
    readonly property real smallRadius: root.spec.smallRadius * scale
    readonly property real controlRadius: root.spec.controlRadius * scale
    readonly property real panelRadius: root.spec.panelRadius * scale
    readonly property real roundRadius: root.spec.roundRadius * scale
    readonly property int borderWidth: 1
    readonly property int focusBorderWidth: 2
}
