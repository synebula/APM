import "../../theme"
import "../../theme/colors/runtime/ColorMath.js" as ColorMath
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
        implicitWidth: Theme.components.sectionHeader.iconContainerSize
        implicitHeight: implicitWidth
        radius: Theme.shape.controlRadius
        color: ColorMath.alpha(root.tone, 0.15)

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
            objectName: "sectionTitle"
            text: root.title
            font: Theme.typography.title
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
