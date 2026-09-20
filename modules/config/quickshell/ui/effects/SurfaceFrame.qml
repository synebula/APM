import "../../theme"
import QtQuick
import QtQuick.Effects

Rectangle {
    id: root

    property color fill: Theme.components.surface.fill
    property int borderWidth: Theme.components.surface.borderWidth
    property color borderColor: Theme.components.surface.borderColor
    property real blurRadius: Theme.components.surface.blurRadius
    property bool shadowEnabled: Theme.components.surface.shadowEnabled
    property bool highlightEnabled: Theme.components.surface.highlightEnabled
    readonly property bool isTranslucent: Theme.components.surface.isGlass || root.fill.a < 1.0
    readonly property bool isLiquid: Theme.components.surface.isLiquid
    // 液态装饰只作用于真实可见的玻璃面；透明底的按钮背景不应出现光边
    readonly property bool hasSurface: root.color.a > 0.05
    readonly property color shadeColor: Qt.rgba(0, 0, 0, Theme.isDark ? 0.28 : 0.14)
    readonly property color liquidBorderColor: Qt.rgba(
        Theme.isDark ? 0.95 : 1.0,
        Theme.isDark ? 0.98 : 1.0,
        1.0,
        (Theme.isDark ? 0.40 : 0.65) * Theme.components.surface.fresnelStrength
    )

    color: Qt.rgba(root.fill.r, root.fill.g, root.fill.b, root.fill.a * Theme.components.surface.fillOpacity)
    radius: Theme.shape.panelRadius
    border.width: root.borderWidth
    border.color: root.isLiquid ? root.liquidBorderColor : root.borderColor
    antialiasing: true
    smooth: true
    gradient: !root.isTranslucent && Theme.components.surface.isGradient ? plateGradient
            : (root.isLiquid ? liquidGradient : null)
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

    Gradient {
        id: liquidGradient

        GradientStop {
            position: 0.0
            color: Qt.rgba(
                Math.min(1.0, root.fill.r * Theme.components.surface.gradientLighten),
                Math.min(1.0, root.fill.g * Theme.components.surface.gradientLighten),
                Math.min(1.0, root.fill.b * Theme.components.surface.gradientLighten),
                root.fill.a * Theme.components.surface.fillOpacity * 0.85
            )
        }

        GradientStop {
            position: 1.0
            color: Qt.rgba(
                root.fill.r * Theme.components.surface.gradientDarken,
                root.fill.g * Theme.components.surface.gradientDarken,
                root.fill.b * Theme.components.surface.gradientDarken,
                root.fill.a * Theme.components.surface.fillOpacity * 1.15
            )
        }
    }

    // 液态玻璃：顶部天光透镜弧面高光（Skyline Specular Dome）
    Rectangle {
        id: liquidSpecularDome

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 1
        }
        height: Math.max(2, Math.min(parent.height * 0.42, root.radius * 1.5))
        radius: Math.max(0, root.radius - 1)
        color: "transparent"
        clip: true
        visible: root.isLiquid && root.hasSurface && root.highlightEnabled && parent.height > 6
        enabled: false
        antialiasing: true

        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop {
                position: 0.0
                color: Qt.rgba(1.0, 1.0, 1.0, (Theme.isDark ? 0.28 : 0.55) * Theme.components.surface.specularOpacity)
            }
            GradientStop {
                position: 0.35
                color: Qt.rgba(1.0, 1.0, 1.0, (Theme.isDark ? 0.10 : 0.20) * Theme.components.surface.specularOpacity)
            }
            GradientStop {
                position: 1.0
                color: "transparent"
            }
        }
    }

    // 液态玻璃：底部次级微聚光弧
    Rectangle {
        id: liquidCausticRim

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Math.max(root.radius * 0.5, 4)
            rightMargin: Math.max(root.radius * 0.5, 4)
            bottomMargin: 1
        }
        height: 1
        radius: 0.5
        visible: root.isLiquid && root.hasSurface && parent.width > root.radius * 2
        enabled: false
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: "transparent"
            }
            GradientStop {
                position: 0.3
                color: Qt.rgba(1.0, 1.0, 1.0, Theme.isDark ? 0.15 : 0.30)
            }
            GradientStop {
                position: 0.7
                color: Qt.rgba(1.0, 1.0, 1.0, Theme.isDark ? 0.15 : 0.30)
            }
            GradientStop {
                position: 1.0
                color: "transparent"
            }
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
        visible: !root.isLiquid && root.highlightEnabled && root.fill.a > 0.05 && (parent.width > root.radius * 2 + 4) && (root.radius < parent.height / 2 - 1)
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

    // 底部内侧暗色镜边：与顶部高光成对，营造玻璃的双色调 rim
    Rectangle {
        id: shadeLine

        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Math.max(root.radius, 2)
            rightMargin: Math.max(root.radius, 2)
            bottomMargin: 1
        }
        height: 1
        radius: 0.5
        enabled: false
        visible: !root.isLiquid && root.isTranslucent && root.fill.a > 0.05 && (parent.width > root.radius * 2 + 4) && (root.radius < parent.height / 2 - 1)
        gradient: Gradient {
            orientation: Gradient.Horizontal
            GradientStop {
                position: 0.0
                color: "transparent"
            }
            GradientStop {
                position: 0.25
                color: root.shadeColor
            }
            GradientStop {
                position: 0.75
                color: root.shadeColor
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
