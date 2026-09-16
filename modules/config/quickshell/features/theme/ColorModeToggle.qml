pragma ComponentBehavior: Bound
import "../../theme"
import "../../ui/controls"
import QtQuick
import QtQuick.Templates as T

T.Switch {
    id: root

    implicitWidth: Math.round(60 * Theme.controlScale)
    implicitHeight: Math.round(28 * Theme.controlScale)
    padding: 0
    hoverEnabled: true
    Accessible.name: root.checked ? "深色模式" : "浅色模式"

    indicator: Rectangle {
        implicitWidth: root.implicitWidth
        implicitHeight: root.implicitHeight
        radius: height / 2
        color: Theme.components.colorModeToggle.trackColor(root.checked)
        border.width: root.visualFocus ? Theme.shape.borderWidth : 1
        border.color: Theme.components.colorModeToggle.trackBorder(root.checked)

        Behavior on color {
            ColorAnimation { duration: Theme.motion.fastEffects.duration }
        }

        IconGlyph {
            text: "󰖙"
            color: Theme.components.colorModeToggle.iconColor(!root.checked)
            font.pixelSize: Math.round(14 * Theme.controlScale)
            opacity: root.checked ? 0.65 : 1
            x: Math.round(7 * Theme.controlScale)
            anchors.verticalCenter: parent.verticalCenter

            Behavior on opacity {
                NumberAnimation { duration: Theme.motion.fastEffects.duration }
            }
        }

        IconGlyph {
            text: "󰖔"
            color: Theme.components.colorModeToggle.iconColor(root.checked)
            font.pixelSize: Math.round(14 * Theme.controlScale)
            opacity: root.checked ? 1 : 0.65
            x: parent.width - width - Math.round(7 * Theme.controlScale)
            anchors.verticalCenter: parent.verticalCenter

            Behavior on opacity {
                NumberAnimation { duration: Theme.motion.fastEffects.duration }
            }
        }

        Rectangle {
            id: thumb

            z: 1
            width: parent.height - Math.round(6 * Theme.controlScale)
            height: width
            x: root.checked ? parent.width - width - Math.round(3 * Theme.controlScale) : Math.round(3 * Theme.controlScale)
            anchors.verticalCenter: parent.verticalCenter
            radius: width / 2
            color: Theme.components.colorModeToggle.knobColor(root.checked)
            border.width: 1
            border.color: Theme.components.colorModeToggle.knobBorder(root.checked)

            Behavior on x {
                NumberAnimation {
                    duration: Theme.motion.standard.duration
                    easing.type: Theme.motion.standard.easing
                    easing.bezierCurve: Theme.motion.standard.curve
                }
            }

            Behavior on color {
                ColorAnimation { duration: Theme.motion.fastEffects.duration }
            }

            IconGlyph {
                anchors.centerIn: parent
                text: root.checked ? "󰖔" : "󰖙"
                color: Theme.components.colorModeToggle.knobForeground(root.checked)
                font.pixelSize: Math.round(13 * Theme.controlScale)
            }
        }
    }
}
