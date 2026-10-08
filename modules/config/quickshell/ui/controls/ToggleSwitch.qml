import "../../theme"
import "../animations"
import QtQuick
import QtQuick.Templates as T

T.Switch {
    id: root

    implicitWidth: Math.round(38 * Theme.controlScale)
    implicitHeight: Math.round(20 * Theme.controlScale)
    padding: 0
    hoverEnabled: true
    opacity: enabled ? 1 : Theme.disabledOpacity

    indicator: Rectangle {
        implicitWidth: root.implicitWidth
        implicitHeight: root.implicitHeight
        radius: Math.min(height / 2, Theme.shape.controlRadius)
        color: Theme.components.toggleSwitch.trackColor(root.enabled, root.checked)
        border.width: root.visualFocus ? Theme.shape.borderWidth : 0
        border.color: Theme.components.toggleSwitch.borderColor(root.visualFocus)

        Behavior on color {
            ThemeColorAnimation {}
        }

        Rectangle {
            x: root.checked ? parent.width - width - Theme.spacing.tiny : Theme.spacing.tiny
            anchors.verticalCenter: parent.verticalCenter
            width: parent.height - Theme.spacing.tiny * 2
            height: width
            radius: Math.min(width / 2, Theme.shape.controlRadius)
            color: Theme.components.toggleSwitch.knobColor(root.enabled, root.checked)

            Behavior on color {
                ThemeColorAnimation {}
            }

            Behavior on x {
                SlideAnimation {
                    property: "x"
                    motion: Theme.motion.fastEffects
                }
            }
        }
    }
}
