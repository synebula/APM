import "../../theme/motion"
import "../../theme"
import "../controllers"
import "../effects"
import "../animations"
import QtQuick
import Quickshell
import Quickshell.Wayland

// Custom shell panels use a small layer surface instead of xdg_popup. Niri's
// popup rule treats xdg_popup blur as a window-level effect, so it cannot follow
// the card's exit animation. The client blur region is the single source of
// truth for this card.
PanelWindow {
    id: root

    property Item anchorItem: null
    property var barWindow: null
    property var ownerScreen: root.barWindow ? root.barWindow.screen : null
    property bool alignRight: false
    property bool alignLeft: false
    property bool enableBackdrop: true
    property bool dimBackdrop: false
    property int contentWidth: 200
    property int contentHeight: 200
    property bool isOpen: false
    property bool surfaceStarted: false
    property bool blurActive: false
    default property alias content: cardContent.data

    // 反应式记录锚点在 barWindow.contentItem 坐标系下的几何数据
    property real _anchorX: 0
    property real _anchorY: 0
    property real _anchorWidth: root.anchorItem ? root.anchorItem.width : 0
    property real _anchorHeight: root.anchorItem ? root.anchorItem.height : 0

    function updateAnchorGeometry() {
        if (!root.anchorItem) {
            root._anchorX = 0;
            root._anchorY = 0;
            root._anchorWidth = 0;
            root._anchorHeight = 0;
            return;
        }

        root._anchorWidth = root.anchorItem.width;
        root._anchorHeight = root.anchorItem.height;

        const target = (root.barWindow && root.barWindow.contentItem)
            ? root.barWindow.contentItem
            : null;

        if (target) {
            try {
                const mapped = root.anchorItem.mapToItem(target, 0, 0);
                if (mapped && typeof mapped.x === "number" && typeof mapped.y === "number") {
                    root._anchorX = mapped.x;
                    root._anchorY = mapped.y;
                    return;
                }
            } catch (e) {}
        }

        root._anchorX = root.anchorItem.x;
        root._anchorY = root.anchorItem.y;
    }

    onAnchorItemChanged: root.updateAnchorGeometry()
    onBarWindowChanged: root.updateAnchorGeometry()

    Connections {
        target: root.anchorItem

        function onXChanged() { root.updateAnchorGeometry(); }
        function onYChanged() { root.updateAnchorGeometry(); }
        function onWidthChanged() { root.updateAnchorGeometry(); }
        function onHeightChanged() { root.updateAnchorGeometry(); }
        function onVisibleChanged() { root.updateAnchorGeometry(); }
    }

    Connections {
        target: root.barWindow

        function onWidthChanged() { root.updateAnchorGeometry(); }
        function onHeightChanged() { root.updateAnchorGeometry(); }
    }

    // Keep the surface alive only for the visual transition. The blur region is
    // cleared before the exit animation, so unmapping after the last frame does
    // not leave a second, stale popup surface behind.
    property real transitionProgress: root.isOpen ? 1.0 : 0.0
    readonly property real visibilityCutoff: 0.04

    // 入场：缓出曲线，位移比淡入稍长以形成层次；退场：更短的加速曲线
    // （不用 spatial：其过冲在 8px 位移下不足 1px，不可见却多出百余毫秒）
    readonly property MotionSpec enterMotion: Theme.motion.standard
    readonly property MotionSpec exitMotion: Theme.motion.accelerate

    signal opened

    function toggle() {
        if (root.isOpen)
            root.close();
        else
            root.open();
    }

    function open() {
        releaseTimer.stop();
        root.updateAnchorGeometry();
        PopupCoordinator.activate(root);
        root.surfaceStarted = true;
        root.isOpen = true;
        root.blurActive = true;
        root.opened();
    }

    function close() {
        if (!root.isOpen)
            return;

        // Disable the effect before starting the visual exit. This ordering is
        // intentional: the compositor must receive the region removal before
        // the card begins moving/fading.
        root.blurActive = false;
        // Stop publishing the blur region before the exit animation changes
        // the card. The target is fixed, so the compositor can remove one
        // stable region instead of chasing a moving/fading card.
        blurRegion.clear();
        root.isOpen = false;
        if (!transitionAnimation.running)
            releaseTimer.restart();
    }

    readonly property real slideDistance: Theme.components.popup.slideDistance

    readonly property real _popupX: {
        const anchorLeft = root._anchorX;
        const anchorWidth = root._anchorWidth;
        const anchorRight = anchorLeft + anchorWidth;
        const anchorCenter = anchorLeft + (anchorWidth / 2);

        let desired = anchorLeft;
        if (root.alignRight) {
            desired = anchorRight - root.contentWidth;
        } else if (root.alignLeft) {
            desired = anchorLeft;
        } else {
            // 默认居中对齐到锚点中心
            desired = anchorCenter - (root.contentWidth / 2);
        }

        const margin = Theme.spacing.small;
        const screenWidth = root.ownerScreen ? root.ownerScreen.width
            : (root.screen ? root.screen.width
            : (root.barWindow ? root.barWindow.width : (root.contentWidth + margin * 2)));
        const maxX = Math.max(margin, screenWidth - root.contentWidth - margin);
        return Math.round(Math.max(margin, Math.min(maxX, desired)));
    }

    readonly property real _popupY: {
        const barBottom = (root.barWindow && root.barWindow.height > 0)
            ? root.barWindow.height
            : (root._anchorY + root._anchorHeight);
        return Math.round(barBottom + Theme.components.popup.gap);
    }

    screen: root.ownerScreen
    color: "transparent"
    exclusiveZone: -1
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-popup"
    WlrLayershell.exclusionMode: ExclusionMode.Ignore
    anchors {
        top: true
        left: true
    }
    margins.left: root._popupX
    margins.top: root._popupY - root.slideDistance
    implicitWidth: root.contentWidth
    implicitHeight: root.contentHeight + root.slideDistance
    // Mapping is tied to the transition. The surface remains mapped while the
    // card exits, then releaseTimer unmaps it after the final frame.
    visible: root.surfaceStarted
    // Only the card participates in input. Clicks outside it continue to reach
    // PopupBackdrop below this overlay surface.
    mask: Region {
        item: root.isOpen ? card : null
        radius: card.radius
    }
    Component.onDestruction: PopupCoordinator.release(root)

    Timer {
        id: releaseTimer

        // Allow the final frame/region removal to reach the compositor after
        // the animation actually stops, including when its profile changes.
        interval: 32
        repeat: false
        onTriggered: {
            if (!root.isOpen && !transitionAnimation.running && root.transitionProgress <= root.visibilityCutoff) {
                root.surfaceStarted = false;
                PopupCoordinator.release(root);
            }
        }
    }

    Behavior on transitionProgress {
        id: transition
        MotionAnimation {
            id: transitionAnimation
            // Behavior publishes targetValue before starting its animation.
            motion: transition.targetValue === 1 ? root.enterMotion : root.exitMotion
            onRunningChanged: {
                if (!running && !root.isOpen)
                    releaseTimer.restart();
            }
        }
    }

    SurfaceFrame {
        id: card

        x: 0
        // The layer surface starts slideDistance above the final card position;
        // the card enters downward and leaves upward, matching a bar popup.
        y: root.slideDistance * root.transitionProgress
        width: root.contentWidth
        height: root.contentHeight
        fill: Theme.surface.fill
        radius: Theme.shape.panelRadius
        // A compositor blur region is binary and can arrive before the first
        // painted QML frame. Keep the card fully visible on entry so the user
        // never sees an empty blurred rectangle; the exit still fades out.
        opacity: root.isOpen ? 1.0 : root.transitionProgress

        CompositorBlurRegion {
            id: blurRegion

            targetWindow: root
            backgroundItem: blurTarget
            radius: card.radius
            // Blur is binary at the compositor level. Remove it as soon as
            // exit starts instead of keeping a full-strength blur behind a
            // card that is already fading out.
            effectEnabled: root.blurActive
        }

        FocusScope {
            id: cardContent

            anchors.fill: parent
            focus: root.isOpen
            Keys.onEscapePressed: root.close()
        }

    }

    // Keep the compositor region at the settled card geometry. A region tied
    // to card.y is necessarily one commit behind during the QML animation and
    // becomes a visible blur trail on exit.
    Item {
        id: blurTarget

        x: 0
        y: root.slideDistance
        width: root.contentWidth
        height: root.contentHeight
        visible: root.blurActive
    }
}
