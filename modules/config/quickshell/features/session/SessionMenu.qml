pragma ComponentBehavior: Bound
import QtQuick

import "../../theme"
import "../../ui/containers"
import "../../ui/controls"

PopupPanel {
    id: root
    contentWidth: Math.round(160 * Theme.controlScale)
    contentHeight: actions.implicitHeight + Theme.components.popup.padding * 2
    alignRight: true
    dimBackdrop: true

    Column {
        id: actions
        anchors.centerIn: parent
        width: parent.width - Theme.components.popup.padding * 2
        spacing: Theme.spacing.small
        Repeater {
            model: SessionActions.actions
            delegate: ActionRow {
                required property var modelData
                width: actions.width
                text: modelData.label
                glyph: modelData.glyph
                destructive: modelData.destructive
                onClicked: {
                    root.close();
                    SessionActions.request(modelData.actionId);
                }
            }
        }
    }
}
