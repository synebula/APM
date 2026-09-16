import "../../theme"
import "../controllers"
import QtQuick

ActionButton {
    id: root

    property bool active: false
    property bool urgent: false
    default property alias content: inner.data

    signal rightClicked
    signal middleClicked
    signal wheel(var event)

    fillColor: root.active ? Theme.colors.accent : (root.urgent ? Theme.colors.danger : "transparent")
    foreground: root.active ? Theme.colors.accentForeground : Theme.colors.textPrimary
    implicitHeight: Theme.components.barButton.height
    implicitWidth: Math.max(implicitHeight, implicitContentWidth + leftPadding + rightPadding)
    height: implicitHeight
    topPadding: 0
    bottomPadding: 0
    leftPadding: Theme.components.barButton.padding
    rightPadding: Theme.components.barButton.padding

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.RightButton | Qt.MiddleButton
        cursorShape: Qt.PointingHandCursor
        onClicked: event => {
            TooltipController.hide(root);
            if (event.button === Qt.MiddleButton)
                root.middleClicked();
            else
                root.rightClicked();
        }
        onWheel: event => {
            return root.wheel(event);
        }
    }

    contentItem: Item {
        id: contentContainer

        implicitWidth: inner.implicitWidth
        implicitHeight: inner.implicitHeight

        Row {
            id: inner

            anchors.centerIn: parent
            spacing: Theme.spacing.small
        }
    }
}
