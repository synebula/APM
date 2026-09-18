import "../../theme"
import "../effects"
import QtQuick

Item {
    id: root

    default property alias content: row.data

    implicitHeight: Theme.components.barGroup.height
    height: implicitHeight
    visible: row.implicitWidth > 0
    implicitWidth: visible ? Math.max(height, row.implicitWidth + Theme.components.barGroup.padding * 2) : 0

    SurfaceFrame {
        anchors.fill: parent
        fill: Theme.components.barGroup.background
        radius: Theme.components.barGroup.radius
    }

    Row {
        id: row

        anchors.centerIn: parent
        spacing: Theme.spacing.small
    }
}
