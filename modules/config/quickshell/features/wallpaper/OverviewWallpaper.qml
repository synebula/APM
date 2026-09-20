import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../../config"
import "../../services"

PanelWindow {
    id: root

    color: "transparent"

    visible: WallpaperSettings.overviewEnabled

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "quickshell-overview-wallpaper"
    WlrLayershell.exclusionMode: ExclusionMode.Ignore

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }

    // 将输入掩码区域置空，使鼠标点击事件完全穿透到底层桌面
    mask: Region {
        item: Item {}
    }

    Item {
        id: container
        anchors.fill: parent

        readonly property int blurOverflow: WallpaperSettings.overviewBlurRadius > 0 ? 64 : 0

        WallpaperTransitionSurface {
            id: renderer

            anchors.fill: parent
            anchors.margins: -container.blurOverflow
            sourcePath: WallpaperService.wallpaperForScreen(root.screen ? root.screen.name : "")
            transitionDurationMs: WallpaperSettings.transitionDurationMs

            layer.enabled: WallpaperSettings.overviewBlurRadius > 0
                           || WallpaperSettings.overviewSaturation !== 1
                           || WallpaperSettings.overviewContrast !== 1
            layer.effect: MultiEffect {
                blurEnabled: WallpaperSettings.overviewBlurRadius > 0
                blur: WallpaperSettings.overviewBlurRadius / 100.0
                blurMax: 64
                saturation: WallpaperSettings.overviewSaturation - 1.0
                contrast: WallpaperSettings.overviewContrast - 1.0
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "#000000"
            opacity: WallpaperSettings.overviewDim
        }
    }
}
