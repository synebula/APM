pragma ComponentBehavior: Bound
import "../../theme"
import QtQuick
import QtQuick.Effects

Item {
    id: root

    required property vector2d mainCenter
    required property vector2d mainSize
    required property real mainRadius
    required property vector2d satelliteCenter
    required property vector2d satelliteSize
    required property real satelliteRadius
    required property real blendRadius

    property color surfaceColor: Qt.rgba(
        Theme.surface.fill.r,
        Theme.surface.fill.g,
        Theme.surface.fill.b,
        Theme.surface.fill.a * Theme.surface.fillOpacity
    )
    property real edgeSoftness: 0.8
    property bool shadowEnabled: Theme.surface.shadowEnabled && !Theme.surface.isGlass

    Item {
        id: surfaceContainer
        anchors.fill: parent

        layer.enabled: root.shadowEnabled
        layer.smooth: true
        layer.effect: MultiEffect {
            shadowEnabled: root.shadowEnabled
            shadowColor: Theme.surface.shadowColor
            shadowBlur: Theme.surface.shadowBlur
            shadowHorizontalOffset: Theme.surface.shadowHorizontalOffset
            shadowVerticalOffset: Theme.surface.shadowVerticalOffset
        }

        ShaderEffect {
            id: morphShader
            anchors.fill: parent

            property vector2d resolution: Qt.vector2d(width, height)
            property color fillColor: root.surfaceColor
            property vector2d mainCenter: root.mainCenter
            property vector2d mainSize: root.mainSize
            property real mainRadius: root.mainRadius
            property vector2d satelliteCenter: root.satelliteCenter
            property vector2d satelliteSize: root.satelliteSize
            property real satelliteRadius: root.satelliteRadius
            property real blendRadius: root.blendRadius
            property real edgeSoftness: root.edgeSoftness

            fragmentShader: Qt.resolvedUrl("shaders/pill_morph.frag.qsb")
        }
    }
}
