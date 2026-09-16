import "../../theme"
import QtQuick
import QtQuick.Templates as T

T.Switch {
    id: root

    implicitWidth: Math.round(38 * Theme.controlScale)
    implicitHeight: Math.round(20 * Theme.controlScale)
    padding: 0
    hoverEnabled: true
    opacity: enabled ? 1 : 0.4

    indicator: Rectangle {
        implicitWidth: root.implicitWidth
        implicitHeight: root.implicitHeight
        radius: Math.min(height / 2, Theme.shape.controlRadius)
        color: Theme.components.toggleSwitch.trackColor(root.enabled, root.checked)
        border.width: root.visualFocus ? Theme.shape.borderWidth : 0
        border.color: Theme.components.toggleSwitch.borderColor(root.visualFocus)

        Behavior on color {
            ColorAnimation { duration: Theme.motion.standard.duration }
        }

        Rectangle {
            x: root.checked ? parent.width - width - Theme.spacing.tiny : Theme.spacing.tiny
            anchors.verticalCenter: parent.verticalCenter
            width: parent.height - Theme.spacing.tiny * 2
            height: width
            radius: Math.min(width / 2, Theme.shape.controlRadius)
            color: Theme.components.toggleSwitch.knobColor(root.enabled, root.checked)

            Behavior on color {
                ColorAnimation { duration: Theme.motion.standard.duration }
            }

            Behavior on x {
                NumberAnimation {
                    duration: Theme.motion.fastEffects.duration
                    easing.type: Theme.motion.fastEffects.easing
                    easing.bezierCurve: Theme.motion.fastEffects.curve
                }
            }
        }
    }
}
