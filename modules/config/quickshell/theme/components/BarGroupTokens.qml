import QtQuick
import "../geometry/runtime"
import "../materials/runtime"

QtObject {
    id: root

    required property real controlScale
    required property ShapeTokens shape
    required property real spacingScale
    required property SurfaceTokens surface

    readonly property int height: Math.round(24 * root.controlScale)
    readonly property color background: root.surface.fill
    readonly property int padding: Math.round(6 * root.spacingScale)
    readonly property real radius: Math.min(height / 2, 13 * root.shape.scale)
}
