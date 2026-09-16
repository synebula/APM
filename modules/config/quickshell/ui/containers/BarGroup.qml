import "../../theme"
import "../effects"
import QtQuick

SurfaceFrame {
    id: root

    default property alias content: row.data

    fill: Theme.components.barGroup.background
    radius: Theme.components.barGroup.radius
    implicitHeight: Theme.components.barGroup.height
    height: implicitHeight
    visible: row.implicitWidth > 0
    implicitWidth: visible ? Math.max(height, row.implicitWidth + Theme.components.barGroup.padding * 2) : 0

    Row {
        id: row

        anchors.centerIn: parent
        spacing: Theme.spacing.small
    }
}
