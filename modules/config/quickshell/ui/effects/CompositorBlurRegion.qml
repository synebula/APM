import QtQuick
import Quickshell
import Quickshell.Wayland

Item {
    id: root

    required property var targetWindow
    required property Item backgroundItem
    property real radius: 0
    property bool surfaceReady: false
    property bool destroying: false
    readonly property bool active: root.surfaceReady && root.targetWindow && root.targetWindow.visible && root.backgroundItem.visible && root.backgroundItem.width > 0 && root.backgroundItem.height > 0

    function publish() {
        if (!root.destroying)
            commitTimer.restart();
    }

    function clear() {
        if (root.targetWindow)
            root.targetWindow.BackgroundEffect.blurRegion = null;
    }

    visible: false
    onActiveChanged: root.publish()
    Component.onCompleted: {
        root.surfaceReady = root.targetWindow.visible;
        root.publish();
    }
    Component.onDestruction: {
        root.destroying = true;
        commitTimer.stop();
        root.clear();
    }

    Region {
        id: region

        item: root.backgroundItem
        radius: root.radius
        onChanged: root.publish()
    }

    TransformWatcher {
        a: root.targetWindow ? root.targetWindow.contentItem : null
        b: root.backgroundItem
        onTransformChanged: root.publish()
    }

    Timer {
        id: commitTimer

        interval: 0
        onTriggered: {
            if (!root.targetWindow || root.destroying)
                return;

            root.clear();
            if (root.active)
                root.targetWindow.BackgroundEffect.blurRegion = region;
        }
    }

    Connections {
        function onResourcesLost() {
            root.surfaceReady = false;
            root.clear();
        }

        function onWindowConnected() {
            root.surfaceReady = root.targetWindow.visible;
            root.publish();
        }

        function onVisibleChanged() {
            root.surfaceReady = root.targetWindow.visible;
            root.publish();
        }

        target: root.targetWindow
    }
}
