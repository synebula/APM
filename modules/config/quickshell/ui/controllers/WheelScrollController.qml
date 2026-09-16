import "../../theme"
import QtQuick

// ============================================================================
// WheelScrollController (平滑滚轮控制器)
// 精确区分触摸板像素连续滑动与鼠标滚轮步进，实现阻尼平滑过渡与连续快速滚动
// ============================================================================
MouseArea {
    id: root

    required property Flickable flickable
    property int orientation: Qt.Vertical
    property real mouseStep: 120
    property real pixelMultiplier: 3
    readonly property bool horizontal: orientation === Qt.Horizontal
    readonly property real minimum: horizontal ? flickable.originX - flickable.leftMargin : flickable.originY - flickable.topMargin
    readonly property real maximum: Math.max(minimum, horizontal ? flickable.originX + flickable.contentWidth - flickable.width + flickable.rightMargin : flickable.originY + flickable.contentHeight - flickable.height + flickable.bottomMargin)
    property real destination: 0
    property real position: 0
    property bool writingPosition: false
    readonly property real observedContentX: flickable ? flickable.contentX : 0
    readonly property real observedContentY: flickable ? flickable.contentY : 0
    readonly property bool observedDragging: flickable ? flickable.dragging : false
    readonly property bool observedInteractive: flickable ? flickable.interactive : false

    function currentPosition() {
        return horizontal ? flickable.contentX : flickable.contentY;
    }

    function clamp(value) {
        return Math.max(minimum, Math.min(maximum, value));
    }

    function stop() {
        scrollAnimation.stop();
    }

    function constrainAnimation() {
        if (!scrollAnimation.running)
            return;

        const boundedDestination = clamp(destination);
        stop();
        position = clamp(currentPosition());
        destination = boundedDestination;
        scrollAnimation.to = destination;
        scrollAnimation.start();
    }

    function handleWheel(event) {
        event.accepted = false;
        if (!enabled || !flickable.interactive || flickable.dragging)
            return;

        const pixelInput = event.pixelDelta.x !== 0 || event.pixelDelta.y !== 0;
        const vector = pixelInput ? event.pixelDelta : event.angleDelta;
        const amount = horizontal ? (vector.x || vector.y) : vector.y;
        const delta = -amount * (pixelInput ? pixelMultiplier : mouseStep / 120);
        if (!isFinite(delta) || delta === 0)
            return;

        const current = currentPosition();
        const base = scrollAnimation.running && delta * (destination - current) > 0 ? destination : current;
        const next = clamp(base + delta);
        if (next === clamp(base)) {
            event.accepted = scrollAnimation.running && current !== next;
            return;
        }
        stop();
        flickable.cancelFlick();
        destination = next;
        position = current;
        if (pixelInput) {
            position = next;
        } else {
            scrollAnimation.to = next;
            scrollAnimation.start();
        }
        event.accepted = true;
    }

    parent: flickable.contentItem
    x: flickable.contentX
    y: flickable.contentY
    width: flickable.width
    height: flickable.height
    z: -1
    acceptedButtons: Qt.NoButton
    scrollGestureEnabled: true
    onWheel: event => {
        return handleWheel(event);
    }
    onEnabledChanged: {
        if (!enabled) {
            stop();
        }
    }
    onOrientationChanged: stop()
    onMinimumChanged: constrainAnimation()
    onMaximumChanged: constrainAnimation()
    onPositionChanged: {
        writingPosition = true;
        if (horizontal)
            flickable.contentX = position;
        else
            flickable.contentY = position;
        writingPosition = false;
    }
    onObservedContentXChanged: {
        if (horizontal && !writingPosition)
            stop();
    }
    onObservedContentYChanged: {
        if (!horizontal && !writingPosition)
            stop();
    }
    onObservedDraggingChanged: {
        if (observedDragging)
            stop();
    }
    onObservedInteractiveChanged: {
        if (!observedInteractive)
            stop();
    }

    NumberAnimation {
        id: scrollAnimation

        target: root
        property: "position"
        alwaysRunToEnd: false
        duration: Theme.motion.scroll.duration
        easing.type: Theme.motion.scroll.easing
        easing.bezierCurve: Theme.motion.scroll.curve
    }
}
