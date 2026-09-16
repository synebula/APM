import "../../theme"
import QtQuick

// ============================================================================
// ArcGauge (环形弧形仪表盘)
// 纯 Canvas 渲染圆环刻度弧、可选指针 Handle、自适应缺口角与中心图标动画
// ============================================================================
Item {
    // 中心图标颜色

    id: root

    // === 必需属性 ===
    property real value: 0
    // 0.0~1.0 进度值
    property string glyph: ""
    // 中心图标文本
    property color progressColor: Theme.colors.accent
    // 进度弧颜色
    property color trackColor: Theme.colors.surfaceVariant
    // 剩余轨道颜色
    property color handleColor: root.progressColor
    // handle 指针颜色
    property color glyphColor: Theme.colors.textPrimary
    // === 可选微调属性 ===
    property string glyphFont: Theme.typography.iconFamily
    property real glyphSize: 9 * Theme.fontScale
    property real arcRadius: 8.5 * Theme.controlScale
    property real lineWidth: 2.2 * Theme.controlScale
    property real gapAngle: 40
    property real handleSpacing: 3 * Theme.controlScale
    property real handleInner: 1.2 * Theme.controlScale
    property real handleOuter: 2.2 * Theme.controlScale
    property bool showHandle: false
    property int animationDuration: Theme.motion.standard.duration
    // --- 内部动画属性 ---
    readonly property real clampedValue: Math.max(0, Math.min(1, root.value))
    property real displayedAngle: clampedValue * (360 - 2 * root.gapAngle)

    implicitWidth: Theme.components.barButton.height
    implicitHeight: implicitWidth
    // --- 重绘触发器 ---
    onProgressColorChanged: canvas.requestPaint()
    onTrackColorChanged: canvas.requestPaint()
    onHandleColorChanged: canvas.requestPaint()
    onShowHandleChanged: canvas.requestPaint()
    onHandleSpacingChanged: canvas.requestPaint()
    onLineWidthChanged: canvas.requestPaint()
    onArcRadiusChanged: canvas.requestPaint()
    onGapAngleChanged: canvas.requestPaint()
    onDisplayedAngleChanged: canvas.requestPaint()

    Canvas {
        id: canvas

        anchors.fill: parent
        antialiasing: true
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const centerX = width / 2;
            const centerY = height / 2;
            const radius = root.arcRadius;
            const lw = root.lineWidth;
            ctx.lineCap = "round";
            // 基础起始角：6 点钟方向 + gapAngle
            const baseStartAngle = (Math.PI / 2) + (root.gapAngle * Math.PI / 180);
            const progressAngleRad = root.displayedAngle * Math.PI / 180;
            const segmentGapRad = root.showHandle ? (lw + root.handleSpacing) / radius : 0;
            // 1. 进度弧
            const progressEndAngle = baseStartAngle + progressAngleRad;
            if (root.displayedAngle > 1 && progressEndAngle > (baseStartAngle + 0.01)) {
                ctx.strokeStyle = root.progressColor;
                ctx.lineWidth = lw;
                ctx.beginPath();
                ctx.arc(centerX, centerY, radius, baseStartAngle, progressEndAngle, false);
                ctx.stroke();
            }
            // 2. 指针 Handle（默认关闭，保持与轨道相同的圆角描边）
            if (root.showHandle && root.displayedAngle >= 0) {
                const handleAngle = baseStartAngle + progressAngleRad;
                const innerR = radius - root.handleInner;
                const outerR = radius + root.handleOuter;
                const innerX = centerX + innerR * Math.cos(handleAngle);
                const innerY = centerY + innerR * Math.sin(handleAngle);
                const outerX = centerX + outerR * Math.cos(handleAngle);
                const outerY = centerY + outerR * Math.sin(handleAngle);
                ctx.strokeStyle = root.handleColor;
                ctx.lineWidth = lw;
                ctx.beginPath();
                ctx.moveTo(innerX, innerY);
                ctx.lineTo(outerX, outerY);
                ctx.stroke();
            }
            // 3. 剩余轨道弧
            const remainingStart = baseStartAngle + progressAngleRad + segmentGapRad;
            const totalAngle = (360 - 2 * root.gapAngle) * Math.PI / 180;
            const remainingEnd = baseStartAngle + totalAngle;
            if (remainingStart < remainingEnd) {
                ctx.strokeStyle = root.trackColor;
                ctx.lineWidth = lw;
                ctx.beginPath();
                ctx.arc(centerX, centerY, radius, remainingStart, remainingEnd, false);
                ctx.stroke();
            }
        }
    }

    // 中心图标
    Text {
        anchors.centerIn: parent
        text: root.glyph
        font.family: root.glyphFont
        font.pixelSize: root.glyphSize
        color: root.glyphColor
        visible: root.glyph.length > 0

        Behavior on color {
            ColorAnimation {
                duration: root.animationDuration
                easing.type: Easing.OutCubic
            }
        }
    }

    Behavior on displayedAngle {
        NumberAnimation {
            duration: root.animationDuration
            easing.type: Easing.OutCubic
        }
    }
}
