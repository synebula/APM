import "../../theme"
import QtQuick
import QtQuick.Effects

Rectangle {
    id: root

    property color fill: Theme.colors.surface
    property int borderWidth: Theme.components.surface.borderWidth
    property color borderColor: Theme.components.surface.borderColor
    property real blurRadius: Theme.components.surface.blurRadius
    property bool shadowEnabled: Theme.components.surface.shadowEnabled
    property bool highlightEnabled: Theme.components.surface.highlightEnabled
    readonly property bool isTranslucent: Theme.components.surface.isGlass || root.fill.a < 1.0

    color: Qt.rgba(root.fill.r, root.fill.g, root.fill.b, root.fill.a * Theme.components.surface.fillOpacity)
    radius: Theme.shape.panelRadius
    border.width: root.borderWidth
    border.color: root.borderColor
    antialiasing: true
    smooth: true
    gradient: !root.isTranslucent && Theme.components.surface.isGradient ? plateGradient : null
    layer.enabled: !root.isTranslucent && Theme.components.surface.layerEffectsEnabled && (root.shadowEnabled || root.blurRadius > 0)
    layer.smooth: true
    layer.effect: MultiEffect {
        blurEnabled: root.blurRadius > 0
        blur: root.blurRadius
        shadowEnabled: root.shadowEnabled
        shadowColor: Theme.components.surface.shadowColor
        shadowBlur: Theme.components.surface.shadowBlur
        shadowHorizontalOffset: Theme.components.surface.shadowHorizontalOffset
        shadowVerticalOffset: Theme.components.surface.shadowVerticalOffset
    }

    Gradient {
        id: plateGradient

        GradientStop {
            position: 0
            color: Qt.lighter(root.fill, Theme.components.surface.gradientLighten)
        }

        GradientStop {
            position: 1
            color: Qt.darker(root.fill, Theme.components.surface.gradientDarken)
        }
    }

    Rectangle {
        id: highlightLine

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: Math.max(root.radius, 2)
            rightMargin: Math.max(root.radius, 2)
            topMargin: 1
        }
        height: 1
        radius: 0.5
        enabled: false
        visible: root.highlightEnabled && root.fill.a > 0.05 && (parent.width > root.radius * 2 + 4) && (root.radius < parent.height / 2 - 1)
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: "transparent"
            }
            GradientStop {
                position: 0.2
                color: Theme.components.surface.highlightColor
            }
            GradientStop {
                position: 0.8
                color: Theme.components.surface.highlightColor
            }
            GradientStop {
                position: 1.0
                color: "transparent"
            }
        }
    }

    Behavior on color {
        ColorAnimation {
            duration: Theme.motion.standard.duration
        }
    }

    Behavior on border.color {
        ColorAnimation {
            duration: Theme.motion.standard.duration
        }
    }
}
