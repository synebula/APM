import "../../theme"
import QtQuick
import QtQuick.Templates as T

T.Slider {
    id: root

    property color progressColor: Theme.colors.accent

    from: 0
    to: 1
    stepSize: 0.01
    implicitWidth: 200 * Theme.controlScale
    implicitHeight: Theme.components.slider.height
    hoverEnabled: true
    padding: 0
    opacity: enabled ? 1 : Theme.disabledOpacity

    handle: Rectangle {
        implicitWidth: Theme.components.slider.handleSize
        implicitHeight: implicitWidth
        x: root.leftPadding + (root.horizontal ? root.visualPosition * (root.availableWidth - width) : (root.availableWidth - width) / 2)
        y: root.topPadding + (root.horizontal ? (root.availableHeight - height) / 2 : root.visualPosition * (root.availableHeight - height))
        radius: Math.min(width / 2, Theme.shape.controlRadius)
        color: Theme.colors.surface
        border.color: root.progressColor
        border.width: Theme.components.slider.handleBorderWidth(root.visualFocus)
    }

    background: Rectangle {
        x: root.leftPadding + (root.horizontal ? 0 : (root.availableWidth - width) / 2)
        y: root.topPadding + (root.horizontal ? (root.availableHeight - height) / 2 : 0)
        width: root.horizontal ? root.availableWidth : Theme.components.slider.trackHeight
        height: root.horizontal ? Theme.components.slider.trackHeight : root.availableHeight
        radius: Theme.shape.smallRadius
        color: Theme.colors.surfaceVariant
        scale: root.horizontal && root.mirrored ? -1 : 1

        Rectangle {
            y: root.horizontal ? 0 : root.visualPosition * parent.height
            width: root.horizontal ? root.position * parent.width : parent.width
            height: root.horizontal ? parent.height : root.position * parent.height
            radius: Theme.shape.smallRadius
            color: root.progressColor
        }
    }
}
