pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property Item activeItem: null
    property string text: ""
    property bool visible: false

    function show(item, str) {
        if (!item || !str) {
            hide();
            return;
        }
        if (activeItem === item && text === str)
            return;

        activeItem = item;
        text = str;
        visible = false;
        delayTimer.restart();
    }

    function hide(item) {
        if (!item || activeItem === item) {
            delayTimer.stop();
            visible = false;
            activeItem = null;
            text = "";
        }
    }

    Timer {
        id: delayTimer

        interval: 350
        repeat: false
        onTriggered: {
            if (root.activeItem && root.text.length > 0)
                root.visible = true;
        }
    }
}
