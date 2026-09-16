import "../../theme"
import QtQuick

// ============================================================================
// Sparkline (系统历史趋势微线图)
// 纯 Canvas 实时渲染动态平滑趋势折线，支持双轨数据、半透明面积填充与滚动推移采样
// ============================================================================
Item {
    id: root

    property var values: []
    property var secondaryValues: []
    property color lineColor: Theme.colors.accent
    property color secondaryLineColor: Theme.colors.danger
    property color baselineColor: Theme.colors.surfaceVariant
    property real maximum: 0
    property real scaleHeadroom: 1.2
    property bool showGuideLines: true
    property bool fillArea: true
    property bool active: visible
    property int historyLength: 30
    property int updateInterval: 1000
    property real lineWidth: 2 * Theme.controlScale
    property real fillOpacity: 0.16
    property real transitionProgress: 1
    property string accessibilityName: "trend graph"
    readonly property real dataMaximum: {
        let result = 0;
        const series = [values || [], secondaryValues || []];
        for (let seriesIndex = 0; seriesIndex < series.length; seriesIndex += 1) {
            const points = series[seriesIndex];
            for (let index = 0; index < points.length; index += 1) {
                const value = points[index];
                if (typeof value === "number" && isFinite(value))
                    result = Math.max(result, value);
            }
        }
        return result;
    }
    property real scaleMaximum: maximum > 0 ? maximum : Math.max(1, dataMaximum * scaleHeadroom)

    function requestVisiblePaint() {
        if (root.active)
            chart.requestPaint();
    }

    function animateUpdate() {
        if (!root.active) {
            root.transitionProgress = 1;
            return;
        }
        slideAnimation.restart();
    }

    implicitHeight: 36 * Theme.controlScale
    implicitWidth: 100 * Theme.controlScale
    onValuesChanged: animateUpdate()
    onSecondaryValuesChanged: animateUpdate()
    onLineColorChanged: requestVisiblePaint()
    onSecondaryLineColorChanged: requestVisiblePaint()
    onBaselineColorChanged: requestVisiblePaint()
    onShowGuideLinesChanged: requestVisiblePaint()
    onScaleHeadroomChanged: requestVisiblePaint()
    onScaleMaximumChanged: requestVisiblePaint()
    onActiveChanged: requestVisiblePaint()
    onTransitionProgressChanged: requestVisiblePaint()

    NumberAnimation {
        id: slideAnimation

        target: root
        property: "transitionProgress"
        from: 0
        to: 1
        duration: Math.max(250, root.updateInterval) * Theme.motion.scale
        easing.type: Easing.Linear
    }

    Canvas {
        id: chart

        anchors.fill: parent
        antialiasing: true
        visible: root.active
        onWidthChanged: root.requestVisiblePaint()
        onHeightChanged: root.requestVisiblePaint()
        onPaint: {
            const context = getContext("2d");
            context.reset();
            context.clearRect(0, 0, width, height);
            if (!root.active || width <= 1 || height <= 1)
                return;

            const top = Math.max(4, root.lineWidth * 2);
            const bottom = height - 2;
            if (root.showGuideLines) {
                context.lineWidth = 1;
                context.strokeStyle = root.baselineColor;
                context.globalAlpha = 0.4;
                for (let gridIndex = 1; gridIndex <= 2; gridIndex += 1) {
                    const gridY = top + (bottom - top) * gridIndex / 3;
                    context.beginPath();
                    context.moveTo(0, gridY);
                    context.lineTo(width, gridY);
                    context.stroke();
                }
                context.globalAlpha = 1;
            }
            drawSeries(root.values, root.lineColor, root.fillArea);
            drawSeries(root.secondaryValues, root.secondaryLineColor, false);
        }

        function drawSeries(points, color, fill) {
            function traceLine() {
                context.beginPath();
                context.moveTo(linePoints[0].x, linePoints[0].y);
                for (let index = 1; index < linePoints.length; index += 1) {
                    context.lineTo(linePoints[index].x, linePoints[index].y);
                }
            }

            if (!points || points.length === 0)
                return;

            const count = points.length;
            const slots = Math.max(2, root.historyLength);
            const step = width / (slots - 1);
            const slideOffset = count > 1 ? (1 - root.transitionProgress) * step : 0;
            const startX = width - Math.max(0, count - 1) * step + slideOffset;
            const linePoints = [];
            for (let index = 0; index < count; index += 1) {
                const value = points[index];
                if (typeof value !== "number" || !isFinite(value))
                    continue;

                const x = count > 1 ? startX + index * step : width;
                const normalized = Math.max(0, Math.min(1, value / Math.max(1, root.scaleMaximum)));
                const y = bottom - normalized * (bottom - top);
                linePoints.push({
                    "x": x,
                    "y": y
                });
            }
            if (linePoints.length === 0)
                return;

            if (fill && linePoints.length > 1) {
                traceLine();
                context.lineTo(linePoints[linePoints.length - 1].x, bottom);
                context.lineTo(linePoints[0].x, bottom);
                context.closePath();
                context.globalAlpha = root.fillOpacity;
                context.fillStyle = color;
                context.fill();
                context.globalAlpha = 1;
            }
            traceLine();
            context.lineWidth = root.lineWidth;
            context.lineJoin = "miter";
            context.lineCap = "butt";
            context.strokeStyle = color;
            context.stroke();
        }
    }

    Behavior on scaleMaximum {
        NumberAnimation {
            duration: Theme.motion.slowEffects.duration
            easing.type: Easing.Linear
        }
    }
}
