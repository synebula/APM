import "../../theme"
import QtQuick

// ============================================================================
// StateLayer (状态层 - Material 3 State Layer)
// 统一管理 Hover、Pressed、Focused、Selected 等交互状态的半透明叠层
// ============================================================================
Item {
    id: root

    property bool hovered: false
    property bool focused: false
    property bool pressed: false
    property bool selected: false
    property bool selectedEnabled: false
    property color color: Theme.colors.textPrimary
    property color hoverColor: root.color
    property color focusColor: root.color
    property color pressedColor: root.color
    property color selectedColor: Theme.colors.accent
    property real hoverOpacity: 0.08
    property real focusOpacity: 0.1
    property real pressedOpacity: 0.14
    property real selectedOpacity: 0.12
    property real layerRadius: 0
    readonly property bool active: root.enabled && (root.pressed || root.hovered || root.focused || (root.selectedEnabled && root.selected))
    readonly property color activeColor: root.pressed ? root.pressedColor : (root.hovered ? root.hoverColor : (root.focused ? root.focusColor : (root.selectedEnabled && root.selected ? root.selectedColor : root.color)))
    readonly property real activeOpacity: root.pressed ? root.pressedOpacity : (root.hovered ? root.hoverOpacity : (root.focused ? root.focusOpacity : root.selectedOpacity))

    Rectangle {
        anchors.fill: parent
        radius: root.layerRadius
        color: root.activeColor
        opacity: root.active ? root.activeOpacity : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.motion.fastEffects.duration
                easing.type: Theme.motion.fastEffects.easing
                easing.bezierCurve: Theme.motion.fastEffects.curve
            }
        }
    }
}
