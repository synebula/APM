pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland

import "../../theme"
import "../controllers"

PanelWindow {
    id: root

    readonly property var activePopup: PopupCoordinator.activePopup
    readonly property bool shouldShow: activePopup !== null && (activePopup.isOpen ?? true)
    readonly property bool dim: activePopup ? (activePopup.dimBackdrop ?? false) : false

    visible: root.shouldShow || backdropRect.opacity > 0
    color: "transparent"
    exclusiveZone: -1
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: root.dim ? "quickshell-power-backdrop" : "qs-popup-backdrop"
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    margins.top: root.dim ? 0 : Theme.components.bar.height
    WlrLayershell.margins.top: root.dim ? 0 : Theme.components.bar.height

    Rectangle {
        id: backdropRect

        anchors.fill: parent
        color: root.dim ? Theme.colors.scrim : "transparent"
        opacity: root.shouldShow ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.motion.fastEffects.duration
                easing.type: Theme.motion.fastEffects.easing
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.shouldShow
        acceptedButtons: Qt.AllButtons
        onPressed: PopupCoordinator.closeActive()
        onClicked: PopupCoordinator.closeActive()
    }
}
