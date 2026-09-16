import "../../theme"
import QtQuick
import QtQuick.Templates as T

T.ProgressBar {
    id: root

    property color progressColor: Theme.colors.accent

    implicitHeight: Theme.components.slider.trackHeight
    implicitWidth: 160 * Theme.controlScale

    background: Rectangle {
        color: Theme.colors.surfaceVariant
        radius: Theme.shape.smallRadius
    }

    contentItem: Item {
        Rectangle {
            width: root.position * parent.width
            height: parent.height
            radius: Theme.shape.smallRadius
            color: root.progressColor
            x: root.mirrored ? parent.width - width : 0
        }
    }
}
