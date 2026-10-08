pragma ComponentBehavior: Bound
import "../../theme"
import "../effects"
import "../animations"
import QtQuick

Item {
    id: root

    property bool expanded: false
    property real baseWidth: 260
    property real baseHeight: 52
    property color surfaceColor: Qt.rgba(
        Theme.surface.fill.r,
        Theme.surface.fill.g,
        Theme.surface.fill.b,
        Theme.surface.fill.a * Theme.surface.fillOpacity
    )
    property real edgeSoftness: 0.8
    property bool shadowEnabled: Theme.surface.shadowEnabled && !Theme.surface.isGlass
    property bool satelliteClickable: true

    // 默认子组件放入主药丸容器
    default property alias contentData: mainContentContainer.data
    property Component satelliteContent: null
    readonly property alias mainBodyItem: mainContentContainer
    readonly property alias satelliteItem: satelliteItem
    readonly property real mainRadius: currentMainHeight * 0.5
    readonly property real satelliteRadius: satelliteDiameter * 0.5

    signal satelliteClicked

    property real testProgress: -1
    readonly property real pillProgress: testProgress >= 0 ? Math.max(0, Math.min(1, testProgress)) : Math.max(0, Math.min(1, internalProgress))
    readonly property real satelliteAlpha: Math.max(0, Math.min(1, (pillProgress - 0.45) / 0.55))

    property real internalProgress: 0

    Behavior on internalProgress {
        MotionAnimation {
            motion: Theme.motion.symmetric
        }
    }

    onExpandedChanged: {
        internalProgress = expanded ? 1.0 : 0.0;
    }

    function smoothStep(value) {
        const clamped = Math.max(0, Math.min(1, value));
        return clamped * clamped * (3 - 2 * clamped);
    }

    function interpolate(from, to, value) {
        return from + (to - from) * smoothStep(value);
    }

    function morphValue(idle, peak, neck, split, settled) {
        if (pillProgress <= 0.58)
            return interpolate(idle, peak, pillProgress / 0.58);

        if (pillProgress <= 0.76)
            return interpolate(peak, neck, (pillProgress - 0.58) / 0.18);

        if (pillProgress <= 0.8)
            return interpolate(neck, split, (pillProgress - 0.76) / 0.04);

        return interpolate(split, settled, (pillProgress - 0.8) / 0.2);
    }

    function satelliteMorphValue(idle, peak, neck, split, settled) {
        if (pillProgress <= 0.32)
            return idle;

        if (pillProgress <= 0.58)
            return interpolate(idle, peak, (pillProgress - 0.32) / 0.26);

        if (pillProgress <= 0.76)
            return interpolate(peak, neck, (pillProgress - 0.58) / 0.18);

        if (pillProgress <= 0.8)
            return interpolate(neck, split, (pillProgress - 0.76) / 0.04);

        return interpolate(split, settled, (pillProgress - 0.8) / 0.2);
    }

    readonly property real currentMainWidth: morphValue(
        baseWidth,
        baseWidth + 24,
        baseWidth,
        baseWidth - 12,
        baseWidth - 24
    )
    readonly property real currentMainHeight: morphValue(
        baseHeight,
        baseHeight + 8,
        baseHeight + 3,
        baseHeight + 1,
        baseHeight
    )
    readonly property real satelliteDiameter: baseHeight
    readonly property real satelliteOffset: satelliteMorphValue(
        -baseHeight * 0.5,
        baseHeight * 0.72,
        baseHeight * 0.74,
        baseHeight * 0.76,
        baseHeight * 0.76
    )
    readonly property real shadowPadding: root.shadowEnabled ? Math.round(16 * Theme.controlScale) : 0
    readonly property real satelliteCenterX: currentMainWidth + satelliteOffset
    readonly property real visualWidth: Math.max(baseWidth, satelliteCenterX + satelliteDiameter * 0.5)
    readonly property real visualHeight: baseHeight + 12
    readonly property real mainY: (visualHeight - currentMainHeight) * 0.5
    readonly property real satelliteY: (visualHeight - satelliteDiameter) * 0.5
    readonly property real currentBlendRadius: satelliteMorphValue(
        0,
        baseHeight * 0.95,
        baseHeight * 0.55,
        baseHeight * 0.35,
        0
    )

    implicitWidth: visualWidth + shadowPadding * 2
    implicitHeight: visualHeight + shadowPadding * 2

    PillMorphSurface {
        anchors.fill: parent
        mainCenter: Qt.vector2d(root.shadowPadding + root.currentMainWidth * 0.5, root.shadowPadding + root.mainY + root.currentMainHeight * 0.5)
        mainSize: Qt.vector2d(root.currentMainWidth, root.currentMainHeight)
        mainRadius: root.currentMainHeight * 0.5
        satelliteCenter: Qt.vector2d(root.shadowPadding + root.satelliteCenterX, root.shadowPadding + root.satelliteY + root.satelliteDiameter * 0.5)
        satelliteSize: Qt.vector2d(root.satelliteDiameter, root.satelliteDiameter)
        satelliteRadius: root.satelliteDiameter * 0.5
        blendRadius: root.currentBlendRadius
        surfaceColor: root.surfaceColor
        edgeSoftness: root.edgeSoftness
        shadowEnabled: root.shadowEnabled
    }

    // 主药丸内容容器
    Item {
        id: mainContentContainer

        x: root.shadowPadding
        y: root.shadowPadding + root.mainY
        width: root.currentMainWidth
        height: root.currentMainHeight
        clip: true
    }

    // 派生卫星小球容器
    Item {
        id: satelliteItem

        x: root.shadowPadding + root.satelliteCenterX - root.satelliteDiameter * 0.5
        y: root.shadowPadding + root.satelliteY
        width: root.satelliteDiameter
        height: root.satelliteDiameter
        opacity: root.satelliteAlpha
        visible: opacity > 0.01

        Loader {
            anchors.fill: parent
            sourceComponent: root.satelliteContent
        }

        MouseArea {
            id: satelliteMouse

            anchors.fill: parent
            hoverEnabled: true
            enabled: root.satelliteClickable && root.expanded && root.pillProgress > 0.7
            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: root.satelliteClicked()
        }
    }
}
