import QtQuick
import Quickshell
import Quickshell.Wayland
import "../../config"
import "../../services"

PanelWindow {
    id: root

    color: "transparent"

    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "quickshell-wallpaper"
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

    WallpaperTransitionSurface {
        id: renderer

        anchors.fill: parent
        sourcePath: WallpaperService.wallpaperForScreen(root.screen ? root.screen.name : "")
        transitionDurationMs: WallpaperSettings.transitionDurationMs
    }
}
