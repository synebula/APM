pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "."

Singleton {
    id: root

    readonly property int stateSchemaVersion: 1
    readonly property string wallpaperPath: ConfigService.resolvePath(wallpaperData.wallpaperPath.length > 0 ? wallpaperData.wallpaperPath : ConfigService.wallpaper.defaultPath)
    readonly property int transitionDurationMs: {
        const storedDuration = wallpaperData.transitionDurationMs;
        const legacyZero = wallpaperData.schemaVersion < root.stateSchemaVersion && storedDuration === 0;
        if (legacyZero || storedDuration < 0)
            return ConfigService.wallpaper.transitionDurationMs;
        return storedDuration;
    }
    readonly property bool overviewEnabled: wallpaperData.hasOverviewEnabled ? wallpaperData.overviewEnabled : ConfigService.wallpaper.overviewEnabled
    readonly property int overviewBlurRadius: wallpaperData.overviewBlurRadius >= 0 ? wallpaperData.overviewBlurRadius : ConfigService.wallpaper.overviewBlurRadius
    readonly property real overviewDim: wallpaperData.overviewDim >= 0 ? wallpaperData.overviewDim : ConfigService.wallpaper.overviewDim
    readonly property real overviewSaturation: wallpaperData.overviewSaturation >= 0 ? wallpaperData.overviewSaturation : ConfigService.wallpaper.overviewSaturation
    readonly property real overviewContrast: wallpaperData.overviewContrast >= 0 ? wallpaperData.overviewContrast : ConfigService.wallpaper.overviewContrast

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
        wallpaperData.schemaVersion = root.stateSchemaVersion;
        saveTimer.restart();
    }

    function finishLoading(hasPersistedState) {
        if (hasPersistedState && wallpaperData.schemaVersion < root.stateSchemaVersion) {
            // Before the state schema existed, JsonAdapter's default 0 meant
            // "unset". Preserve the global config instead of treating it as
            // an explicit zero-duration preference.
            if (wallpaperData.schemaVersion === 0 && wallpaperData.transitionDurationMs === 0)
                wallpaperData.transitionDurationMs = -1;
            wallpaperData.schemaVersion = root.stateSchemaVersion;
            saveTimer.restart();
        }
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
        onLoaded: root.finishLoading(true)
        onLoadFailed: error => {
            if (error !== FileViewError.FileNotFound)
                console.warn("Cannot load wallpaper settings:", error);
            root.finishLoading(false);
        }
        onSaveFailed: error => console.warn("Cannot save wallpaper settings:", error)

        JsonAdapter {
            id: wallpaperData
            property int schemaVersion: 0
            property string wallpaperPath: ""
            property int transitionDurationMs: -1
            property bool hasOverviewEnabled: false
            property bool overviewEnabled: true
            property int overviewBlurRadius: -1
            property real overviewDim: -1.0
            property real overviewSaturation: -1.0
            property real overviewContrast: -1.0
        }
    }
}
