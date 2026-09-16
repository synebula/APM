import "../../theme"
import QtQuick

ValueSlider {
    id: root

    property bool playing: false
    property real phase: 0

    NumberAnimation on phase {
        from: 0
        to: Math.PI * 2
        duration: Math.max(1, 1200 * Theme.motion.scale)
        loops: Animation.Infinite
        running: root.playing && root.visible && Theme.motion.scale > 0
    }

    background: Canvas {
        id: wave

        property real phase: root.phase
        property real position: root.visualPosition
        property color progressColor: root.progressColor
        property color trackColor: Theme.colors.surfaceVariant

        x: root.leftPadding
        y: root.topPadding
        width: root.availableWidth
        height: root.availableHeight
        onPhaseChanged: requestPaint()
        onPositionChanged: requestPaint()
        onProgressColorChanged: requestPaint()
        onTrackColorChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPaint: {
            const context = getContext("2d");
            context.clearRect(0, 0, width, height);
            context.lineWidth = Math.max(1, Theme.components.slider.trackHeight / 2);
            context.lineCap = Theme.shape.scale > 0 ? "round" : "butt";
            context.strokeStyle = wave.trackColor;
            context.beginPath();
            context.moveTo(0, height / 2);
            context.lineTo(width, height / 2);
            context.stroke();
            const end = root.position * width;
            context.strokeStyle = wave.progressColor;
            context.beginPath();
            for (let x = 0; x <= end; x++) {
                const envelope = Math.min(1, x / 12, (end - x) / 12);
                const y = height / 2 + Math.sin(x * 0.15 / Theme.spacingScale - root.phase) * 2.5 * Theme.spacingScale * envelope;
                if (x === 0)
                    context.moveTo(root.mirrored ? width - x : x, y);
                else
                    context.lineTo(root.mirrored ? width - x : x, y);
            }
            context.stroke();
        }
    }
}
