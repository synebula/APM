pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Wayland

import "../../theme"
import "../controllers"

PanelWindow {
    id: root

    readonly property var activePopup: PopupCoordinator.activePopup
    readonly property bool ownsActivePopup: activePopup !== null && root.screen
        && PopupCoordinator.activeScreenName !== ""
        && root.screen.name === PopupCoordinator.activeScreenName
    readonly property bool shouldShow: root.ownsActivePopup && (activePopup.isOpen ?? true) && (activePopup.enableBackdrop ?? true)
    readonly property bool dim: root.ownsActivePopup && activePopup ? (activePopup.dimBackdrop ?? false) : false
    readonly property real transitionProgress: {
        if (!root.ownsActivePopup || !activePopup)
            return 0;
        const progress = activePopup.transitionProgress;
        if (typeof progress === "number")
            return Math.max(0, Math.min(1, progress));
        return (activePopup.isOpen ?? true) ? 1 : 0;
    }

    visible: root.shouldShow || backdropRect.opacity > 0.01
    color: "transparent"
    exclusiveZone: -1
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: root.dim ? "quickshell-power-backdrop" : "quickshell-popup-backdrop"
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    WlrLayershell.margins.top: root.dim ? 0 : Theme.components.bar.height

    Rectangle {
        id: backdropRect

        anchors.fill: parent
        color: root.dim ? Theme.colors.scrim : "transparent"
        opacity: root.transitionProgress
    }

    MouseArea {
        anchors.fill: parent
        enabled: root.shouldShow
        acceptedButtons: Qt.AllButtons
        onClicked: PopupCoordinator.closeActive()
    }
}
