pragma ComponentBehavior: Bound
import QtQuick
import "../../ui/controls"

BarButton {
    id: root
    property var barWindow: null
    readonly property SessionMenu popup: powerLoader.item as SessionMenu
    objectName: "SessionIndicator"

    tooltipText: "  Power Manage"
    function togglePowerMenu() {
        if (!powerLoader.active) {
            powerLoader.active = true;
            if (root.popup)
                root.popup.open();
        } else if (root.popup) {
            root.popup.toggle();
        }
    }

    onClicked: root.togglePowerMenu()

    content: BarText {
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined
        text: ""
    }

    // Native Quickshell Power Menu
    Loader {
        id: powerLoader
        active: false
        sourceComponent: Component {
            SessionMenu {
                anchorItem: root
                barWindow: root.barWindow
            }
        }
    }
}
