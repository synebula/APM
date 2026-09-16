import "../../theme"
import QtQuick
import QtQuick.Layouts

RowLayout {
    id: root

    property string title: ""
    property string subtitle: ""
    property string glyph: ""
    property color tone: Theme.colors.accent
    default property alias actions: actions.data

    spacing: Theme.spacing.medium

    Rectangle {
        visible: root.glyph.length > 0
        implicitWidth: Theme.components.actionRow.height
        implicitHeight: implicitWidth
        radius: Theme.shape.controlRadius
        color: Qt.rgba(root.tone.r, root.tone.g, root.tone.b, 0.15)

        IconGlyph {
            anchors.centerIn: parent
            text: root.glyph
            color: root.tone
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.spacing.tiny

        TextLabel {
            text: root.title
            font.bold: true
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        TextLabel {
            visible: root.subtitle.length > 0
            text: root.subtitle
            font: Theme.typography.caption
            color: Theme.colors.textSecondary
            elide: Text.ElideRight
            Layout.fillWidth: true
        }
    }

    RowLayout {
        id: actions

        spacing: Theme.spacing.small
    }
}
