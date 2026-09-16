import "../../services"
import "../../theme"
import "../controllers"
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    property bool isOpen: false
    default property alias content: focusScope.data

    signal closeRequested
    signal opened

    function close() {
        root.closeRequested();
    }

    screen: WindowManagerService.focusedScreen
    color: "transparent"
    visible: root.isOpen || backdrop.opacity > 0
    exclusiveZone: -1
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "quickshell-modal"
    onIsOpenChanged: {
        if (root.isOpen) {
            PopupCoordinator.activate(root);
            focusScope.forceActiveFocus();
            root.opened();
        } else {
            PopupCoordinator.release(root);
        }
    }
    Component.onDestruction: PopupCoordinator.release(root)

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    Rectangle {
        id: backdrop

        anchors.fill: parent
        color: Theme.colors.scrim
        opacity: root.isOpen ? 1 : 0

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.motion.fastEffects.duration
            }
        }
    }

    FocusScope {
        id: focusScope

        anchors.fill: parent
        focus: root.isOpen
        opacity: backdrop.opacity
        Keys.onEscapePressed: root.close()
    }
}
