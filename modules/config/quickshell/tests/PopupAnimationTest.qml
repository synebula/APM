import QtQuick
import Quickshell
import Quickshell.Wayland
import "../theme"
import "../theme/appearance"
import "../theme/motion"
import "../ui/containers"
import "../ui/controllers"
import "../ui/controls"

TestSuite {
    id: root
    name: "PopupAnimation"

    property real previousScale: 1

    function init() {
        previousScale = Theme.motion.scale;
        ThemeController.setMotionScale(1);
    }

    function cleanup() {
        ThemeController.setMotionScale(previousScale);
    }

    Component {
        id: popupComponent
        PopupPanel {
            ownerScreen: Quickshell.screens[0]
            contentWidth: 240
            contentHeight: 120
            TextLabel { anchors.centerIn: parent; text: "Popup animation" }
        }
    }

    Component {
        id: modalComponent
        ModalWindow {
            screen: Quickshell.screens[0]
            onCloseRequested: isOpen = false
            Rectangle {
                anchors.centerIn: parent
                width: 240
                height: 120
                color: Theme.colors.surface
            }
        }
    }

    Component {
        id: customMotionComponent
        MotionSpec { duration: 400; easing: Easing.Linear }
    }

    function test_popupClearsBlurBeforeReleasingItsSurface() {
        const popup = createTemporaryObject(popupComponent, root);
        popup.open();
        verify(popup.visible && popup.blurActive);
        tryCompare(popup, "transitionProgress", 1);
        compare(PopupCoordinator.activePopup, popup);
        popup.close();
        verify(!popup.blurActive);
        compare(popup.BackgroundEffect.blurRegion, null);
        verify(popup.visible, "Keep the surface alive for the exit animation");
        tryVerify(() => popup.transitionProgress > 0 && popup.transitionProgress < 1);
        tryCompare(popup, "visible", false);
        verify(popup.transitionProgress <= popup.visibilityCutoff);
        compare(PopupCoordinator.activePopup, null);
    }

    function test_reopenDuringExitKeepsTheSurfaceAndContinues() {
        const popup = createTemporaryObject(popupComponent, root);
        popup.open();
        tryCompare(popup, "transitionProgress", 1);
        popup.close();
        tryVerify(() => popup.transitionProgress > 0 && popup.transitionProgress < 1);
        const atReopen = popup.transitionProgress;
        popup.open();
        compare(popup.transitionProgress, atReopen, "Reopening must not reset the current frame");
        tryCompare(popup, "transitionProgress", 1);
        wait(popup.exitMotion.duration + 64);
        verify(popup.visible && popup.isOpen && popup.blurActive);
        compare(PopupCoordinator.activePopup, popup);
        popup.close();
        tryCompare(popup, "visible", false);
    }

    function test_popupConsumesReplacedThemeMotion() {
        const profile = Theme.definition.motion;
        const oldStandard = profile.standard;
        const motion = createTemporaryObject(customMotionComponent, root);
        const popup = createTemporaryObject(popupComponent, root);
        try {
            profile.standard = motion;
            popup.open();
            wait(80);
            verify(popup.transitionProgress > 0 && popup.transitionProgress < 0.5,
                "Popup progress must use the theme's linear curve instead of a local ease-out");
            tryCompare(popup, "transitionProgress", 1);
            popup.close();
            tryCompare(popup, "visible", false);
        } finally {
            profile.standard = oldStandard;
        }
    }

    function test_disabledMotionStillCleansUpAndCanReopen() {
        ThemeController.setMotionScale(0);
        const popup = createTemporaryObject(popupComponent, root);
        for (let i = 0; i < 2; ++i) {
            popup.open();
            compare(popup.transitionProgress, 1);
            verify(popup.visible);
            popup.close();
            compare(popup.transitionProgress, 0);
            compare(popup.BackgroundEffect.blurRegion, null);
            tryCompare(popup, "visible", false);
            compare(PopupCoordinator.activePopup, null);
        }
    }

    function test_modalRetainsItsWindowUntilFadeCompletes() {
        const modal = createTemporaryObject(modalComponent, root);
        modal.isOpen = true;
        tryCompare(modal, "visible", true);
        wait(Theme.motion.fastEffects.duration + 32);
        modal.close();
        verify(!modal.isOpen);
        verify(modal.visible, "Closing must finish the shared fade before unmapping");
        modal.isOpen = true;
        wait(Theme.motion.fastEffects.duration + 32);
        verify(modal.visible);
        modal.close();
        tryCompare(modal, "visible", false);
        ThemeController.setMotionScale(0);
        modal.isOpen = true;
        verify(modal.visible);
        modal.close();
        verify(!modal.visible);
        compare(PopupCoordinator.activePopup, null);
    }
}
