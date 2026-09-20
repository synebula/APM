import "../../theme"
import QtQuick
import Quickshell
import Quickshell.Wayland

Item {
    id: root

    required property var targetWindow
    property Item backgroundItem: null
    property real radius: 0
    property bool enabled: Theme.components.surface.isGlass
    property bool surfaceReady: false
    property bool destroying: false
    // 声明式子 Region（默认属性）与 backgroundItem 区域取并集，
    // 用于同一窗口内的多个玻璃块（如状态栏药丸）；item 为 null 的子区域不参与。
    default property alias regions: region.regions
    readonly property bool ownRegionActive: root.backgroundItem
        && root.backgroundItem.visible
        && root.backgroundItem.width > 0
        && root.backgroundItem.height > 0
    readonly property bool active: root.enabled && root.surfaceReady && root.targetWindow
        && root.targetWindow.visible && (root.ownRegionActive || root.regions.length > 0)

    function commit() {
        if (!root.targetWindow || root.destroying)
            return;

        if (root.active) {
            root.targetWindow.BackgroundEffect.blurRegion = region;
        } else {
            root.clear();
        }
    }

    function publish() {
        if (root.destroying)
            return;

        commitTimer.restart();
        settleTimer.restart();
        animationEndTimer.restart();
    }

    function clear() {
        if (root.targetWindow)
            root.targetWindow.BackgroundEffect.blurRegion = null;
    }

    visible: false
    onActiveChanged: root.publish()
    onEnabledChanged: root.publish()
    onTargetWindowChanged: {
        root.surfaceReady = root.targetWindow ? root.targetWindow.visible : false;
        root.publish();
    }
    Component.onCompleted: {
        root.surfaceReady = root.targetWindow ? root.targetWindow.visible : false;
        root.publish();
    }
    Component.onDestruction: {
        root.destroying = true;
        commitTimer.stop();
        settleTimer.stop();
        animationEndTimer.stop();
        root.clear();
    }

    Region {
        id: region

        item: root.backgroundItem
        radius: root.backgroundItem && root.backgroundItem.height > 0 ? Math.min(root.radius, root.backgroundItem.height / 2) : root.radius
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
        repeat: false
        onTriggered: root.commit()
    }

    Timer {
        id: settleTimer
        interval: 60
        repeat: false
        onTriggered: root.commit()
    }

    Timer {
        id: animationEndTimer
        interval: Math.max(160, Theme.motion.fastEffects.duration + 40)
        repeat: false
        onTriggered: root.commit()
    }

    Connections {
        function onResourcesLost() {
            root.surfaceReady = false;
            root.clear();
        }

        function onWindowConnected() {
            root.surfaceReady = root.targetWindow ? root.targetWindow.visible : false;
            root.publish();
        }

        function onVisibleChanged() {
            const isVis = root.targetWindow ? root.targetWindow.visible : false;
            root.surfaceReady = isVis;
            if (isVis) {
                root.publish();
            } else {
                commitTimer.stop();
                settleTimer.stop();
                animationEndTimer.stop();
                root.clear();
            }
        }

        target: root.targetWindow
    }
}

