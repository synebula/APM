import QtQuick
import ".."
import "../../colors/runtime"

QtObject {
    id: root

    required property MaterialSpec spec
    required property ColorTokens colors
    required property bool isDark
    required property real controlScale

    readonly property color fill: root.isDark ? root.colors.surface : root.colors.background
    readonly property real fillOpacity: root.spec.surface.fillOpacity
    readonly property string mode: root.spec.surface.mode
    readonly property real blurRadius: root.spec.surface.blurRadius
    readonly property int borderWidth: root.spec.border.width
    readonly property bool shadowEnabled: root.spec.elevation.shadowEnabled
    readonly property real shadowBlur: root.spec.elevation.shadowBlur
    readonly property real shadowHorizontalOffset: root.spec.elevation.shadowHorizontalOffset
    readonly property real shadowVerticalOffset: root.spec.elevation.shadowVerticalOffset
    readonly property bool highlightEnabled: root.spec.elevation.highlightEnabled
    readonly property real gradientLighten: root.spec.surface.gradientLighten
    readonly property real gradientDarken: root.spec.surface.gradientDarken
    readonly property real fresnelStrength: root.spec.surface.fresnelStrength
    readonly property real specularOpacity: root.spec.surface.specularOpacity
    // 玻璃面没有实体底衬，文字需要反向描边才能在任何底色上保持边界对比
    readonly property real textHaloOpacity: isGlass ? root.spec.surface.textHaloOpacity : 0
    readonly property color textHaloColor: Qt.rgba(root.isDark ? 0 : 1, root.isDark ? 0 : 1, root.isDark ? 0 : 1, textHaloOpacity)
    readonly property int shadowMargin: shadowEnabled ? Math.round(24 * root.controlScale) : 0
    readonly property bool isLiquid: mode === "liquid"
    readonly property bool isGlass: mode === "acrylic" || isLiquid || fillOpacity < 1.0
    readonly property bool isGradient: mode === "gradient" && !isGlass
    readonly property bool layerEffectsEnabled: !isGlass && (shadowEnabled || blurRadius > 0)

    readonly property color borderColor: {
        const policy = root.spec.border.colorPolicy;
        const source = policy === "surfaceVariant" ? root.colors.surfaceVariant : root.colors.outline;
        if (policy === "transparent")
            return Qt.rgba(0, 0, 0, 0);
        return Qt.rgba(source.r, source.g, source.b, root.spec.border.opacity);
    }
    readonly property ElevationTokens activeElevation: ElevationTokens {
        spec: root.spec.elevation
        isDark: root.isDark
    }

    readonly property color shadowColor: {
        const policy = root.activeElevation.shadowColorPolicy;
        const source = policy === "foreground" ? root.colors.textPrimary : Qt.rgba(0, 0, 0, 1);
        return Qt.rgba(source.r, source.g, source.b, root.activeElevation.shadowOpacity);
    }

    readonly property color highlightColor: Qt.rgba(1, 1, 1, root.activeElevation.highlightOpacity)
}
