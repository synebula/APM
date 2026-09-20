pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "."

Singleton {
    id: root

    readonly property string wallpaperPath: ConfigService.resolvePath(wallpaperData.wallpaperPath && wallpaperData.wallpaperPath.length > 0 ? wallpaperData.wallpaperPath : (ConfigService.wallpaper.defaultPath || ""))
    readonly property int transitionDurationMs: wallpaperData.transitionDurationMs > 0 ? wallpaperData.transitionDurationMs : (ConfigService.wallpaper.transitionDurationMs || 800)
    readonly property bool overviewEnabled: wallpaperData.hasOverviewEnabled ? wallpaperData.overviewEnabled : (ConfigService.wallpaper.overviewEnabled !== false)
    readonly property int overviewBlurRadius: wallpaperData.overviewBlurRadius >= 0 ? wallpaperData.overviewBlurRadius : (ConfigService.wallpaper.overviewBlurRadius !== undefined ? ConfigService.wallpaper.overviewBlurRadius : 48)
    readonly property real overviewDim: wallpaperData.overviewDim >= 0 ? wallpaperData.overviewDim : (ConfigService.wallpaper.overviewDim !== undefined ? ConfigService.wallpaper.overviewDim : 0.3)
    readonly property real overviewSaturation: wallpaperData.overviewSaturation >= 0 ? wallpaperData.overviewSaturation : (ConfigService.wallpaper.overviewSaturation !== undefined ? ConfigService.wallpaper.overviewSaturation : 0.85)
    readonly property real overviewContrast: wallpaperData.overviewContrast >= 0 ? wallpaperData.overviewContrast : (ConfigService.wallpaper.overviewContrast !== undefined ? ConfigService.wallpaper.overviewContrast : 0.9)

    property bool ready: false
    property var pendingChanges: ({})

    function update(changes) {
        if (!root.ready) {
            root.pendingChanges = Object.assign({}, root.pendingChanges, changes);
            return;
        }
        for (const key of Object.keys(changes)) {
            if (key === "overviewEnabled")
                wallpaperData.hasOverviewEnabled = true;
            wallpaperData[key] = changes[key];
        }
        saveTimer.restart();
    }

    function finishLoading() {
        root.ready = true;
        if (Object.keys(root.pendingChanges).length > 0) {
            const changes = root.pendingChanges;
            root.pendingChanges = {};
            root.update(changes);
        }
    }

    Timer {
        id: saveTimer
        interval: 120
        onTriggered: file.writeAdapter()
    }

    FileView {
        id: file
        path: Quickshell.statePath("wallpaper.json")
        preload: true
        printErrors: false
        atomicWrites: true
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.finishLoading()
        onLoadFailed: error => {
            if (error !== FileViewError.FileNotFound)
                console.warn("Cannot load wallpaper settings:", error);
            root.finishLoading();
        }
        onSaveFailed: error => console.warn("Cannot save wallpaper settings:", error)

        JsonAdapter {
            id: wallpaperData
            property string wallpaperPath: ""
            property int transitionDurationMs: 0
            property bool hasOverviewEnabled: false
            property bool overviewEnabled: true
            property int overviewBlurRadius: -1
            property real overviewDim: -1.0
            property real overviewSaturation: -1.0
            property real overviewContrast: -1.0
        }
    }
}
