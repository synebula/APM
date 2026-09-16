import "../../theme"
import QtQuick

ActionButton {
    property bool compact: false

    implicitWidth: compact ? Theme.components.iconButton.compactSize : Theme.components.iconButton.size
    implicitHeight: implicitWidth
    padding: Theme.spacing.small
    Accessible.name: tooltipText
}
