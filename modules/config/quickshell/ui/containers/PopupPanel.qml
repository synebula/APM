import "../../theme"
import "../controllers"
import "../effects"
import QtQuick
import Quickshell

PopupWindow {
    id: root

    property Item anchorItem: null
    property var barWindow: null
    property bool alignRight: false
    property bool enableBackdrop: true
    property bool dimBackdrop: false
    property int contentWidth: 200
    property int contentHeight: 200
    property bool isOpen: false
    default property alias content: cardContent.data

    signal opened

    function toggle() {
        if (root.isOpen)
            root.close();
        else
            root.open();
    }

    function open() {
        hideTimer.stop();
        PopupCoordinator.activate(root);
        root.visible = true;
        root.isOpen = true;
        root.opened();
    }

    function close() {
        if (!root.isOpen)
            return;

        root.isOpen = false;
        hideTimer.restart();
    }

    anchor.window: root.barWindow
    anchor.item: root.anchorItem
    anchor.edges: root.alignRight ? (Edges.Bottom | Edges.Right) : Edges.Bottom
    anchor.gravity: root.alignRight ? (Edges.Bottom | Edges.Left) : Edges.Bottom
    anchor.margins.top: Theme.components.popup.gap
    implicitWidth: root.contentWidth
    implicitHeight: root.contentHeight
    color: "transparent"
    visible: false
    grabFocus: false
    Component.onDestruction: PopupCoordinator.release(root)

    Timer {
        id: hideTimer

        interval: Theme.motion.fastEffects.duration
        onTriggered: {
            if (root.isOpen)
                return;

            root.visible = false;
            PopupCoordinator.release(root);
        }
    }

    SurfaceFrame {
        id: card

        anchors.fill: parent
        fill: Theme.components.surface.fill
        radius: Theme.shape.panelRadius
        opacity: root.isOpen ? 1 : 0

        CompositorBlurRegion {
            targetWindow: root
            backgroundItem: card
            radius: card.radius
        }

        FocusScope {
            id: cardContent

            anchors.fill: parent
            focus: root.isOpen
            Keys.onEscapePressed: root.close()
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.motion.fastEffects.duration
                easing.type: Theme.motion.fastEffects.easing
            }
        }
    }
}
