import "../../theme"
import QtQuick
import QtQuick.Effects

Rectangle {
    id: root

    property color fill: Theme.colors.surface
    property int borderWidth: Theme.components.surface.borderWidth
    property color borderColor: Theme.components.surface.borderColor
    property real blurRadius: Theme.components.surface.blurRadius
    readonly property bool chrome: root.fill.a > 0.99

    color: root.fill
    radius: Theme.shape.panelRadius
    border.width: root.borderWidth
    border.color: root.borderColor
    opacity: Theme.components.surface.fillOpacity
    gradient: root.chrome && Theme.components.surface.mode === "gradient" ? plateGradient : null
    layer.enabled: root.chrome && (Theme.components.surface.shadowEnabled || root.blurRadius > 0)
    layer.effect: MultiEffect {
        blurEnabled: root.blurRadius > 0
        blur: root.blurRadius
        shadowEnabled: true
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
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            leftMargin: 2
            rightMargin: 2
            topMargin: 1
        }
        height: 1
        radius: 1
        enabled: false
        color: Theme.components.surface.highlightColor
        visible: root.chrome && Theme.components.surface.highlightEnabled
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
