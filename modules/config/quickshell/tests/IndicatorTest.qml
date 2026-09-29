import QtQuick
import "../features/audio"
import "../features/bluetooth"
import "../features/theme"
import "../features/session"
import "../ui/controllers"

TestSuite {
    id: root
    name: "Indicators"

    Component { id: audio; AudioIndicator {} }
    Component { id: bluetooth; BluetoothIndicator {} }
    Component { id: theme; ThemeIndicator {} }
    Component { id: session; SessionIndicator {} }

    function test_lazyPopup_data() {
        return [
            { tag: "audio", factory: audio },
            { tag: "bluetooth", factory: bluetooth },
            { tag: "theme", factory: theme },
            { tag: "session", factory: session }
        ];
    }

    function test_lazyPopup(data) {
        const indicator = createTemporaryObject(data.factory, root);
        verify(indicator !== null);
        compare(indicator.popup, null);
        indicator.clicked();
        verify(indicator.popup !== null);
        const popup = indicator.popup;
        verify(popup.isOpen);
        compare(popup.anchorItem, indicator);
        compare(PopupCoordinator.activePopup, popup);
        indicator.clicked();
        verify(!popup.isOpen);
        indicator.clicked();
        compare(indicator.popup, popup, "Opening again must reuse the existing popup");
        verify(popup.isOpen);
        popup.close();
    }
}
