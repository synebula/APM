import "../ui/controllers"
import QtQuick

TestSuite {
    id: root

    name: "PopupCoordinator"

    function test_screenOwnershipUsesStableOutputName() {
        const screen = createTemporaryObject(screenFactory, root, {
            "name": "HDMI-A-1"
        });
        const popup = createTemporaryObject(popupFactory, root, {
            "ownerScreen": screen
        });

        compare(PopupCoordinator.screenNameFor(popup), "HDMI-A-1");

        popup.ownerScreen = null;
        popup.screen = screen;
        compare(PopupCoordinator.screenNameFor(popup), "HDMI-A-1");
    }

    function test_activePopupManagement() {
        const popup1 = createTemporaryObject(popupFactory, root, {});
        const popup2 = createTemporaryObject(popupFactory, root, {});

        PopupCoordinator.activate(popup1);
        compare(PopupCoordinator.activePopup, popup1);

        PopupCoordinator.activate(popup2);
        compare(PopupCoordinator.activePopup, popup2);
        compare(popup1.closeCalled, true);

        PopupCoordinator.release(popup2);
        compare(PopupCoordinator.activePopup, null);
    }

    Component {
        id: screenFactory

        QtObject {
            property string name: ""
        }
    }

    Component {
        id: popupFactory

        QtObject {
            property var barWindow: null
            property var ownerScreen: null
            property var screen: null
            property bool closeCalled: false

            function close() {
                closeCalled = true;
            }
        }
    }
}
