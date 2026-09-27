pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string themeId: appearanceData.themeId
    readonly property string paletteId: appearanceData.paletteId
    readonly property string colorMode: appearanceData.colorMode
    readonly property string accentId: appearanceData.accentId
    readonly property string fontFamily: appearanceData.fontFamily
    readonly property string iconFontFamily: appearanceData.iconFontFamily
    readonly property real fontScale: appearanceData.fontScale
    readonly property real radiusScale: appearanceData.radiusScale
    readonly property real spacingScale: appearanceData.spacingScale
    readonly property real motionScale: appearanceData.motionScale
    readonly property int version: appearanceData.version
    property bool ready: false
    property var pendingChanges: ({})

    function update(changes) {
        if (!root.ready) {
            root.pendingChanges = Object.assign({}, root.pendingChanges, changes);
            return;
        }
        for (const key of Object.keys(changes))
            appearanceData[key] = changes[key];
        saveTimer.restart();
    }

    function migrateStoredState() {
        const storedVersion = Number(appearanceData.version);
        if (!Number.isFinite(storedVersion) || storedVersion < 0) {
            console.warn("AppearanceSettings: invalid state version, resetting to " + 1);
            appearanceData.version = 1;
            return true;
        }
        if (storedVersion > 1) {
            console.warn("AppearanceSettings: unsupported future state version: " + storedVersion);
            return false;
        }

        let changed = storedVersion !== 1;
        const legacySchemes = {
            "catppuccin-latte": { "paletteId": "catppuccin", "colorMode": "light" },
            "catppuccin-mocha": { "paletteId": "catppuccin", "colorMode": "dark" },
            "tokyo-night": { "paletteId": "tokyo-night", "colorMode": "dark" },
            "everforest-dark": { "paletteId": "everforest", "colorMode": "dark" },
            "everforest-light": { "paletteId": "everforest", "colorMode": "light" },
            "nord-dark": { "paletteId": "nord", "colorMode": "dark" },
            "nord-light": { "paletteId": "nord", "colorMode": "light" }
        };

        if (appearanceData.schemeId && appearanceData.schemeId.length > 0) {
            const scheme = appearanceData.schemeId;
            const migration = legacySchemes[scheme];
            if (migration) {
                appearanceData.paletteId = migration.paletteId;
                appearanceData.colorMode = migration.colorMode;
            } else {
                console.warn("AppearanceSettings: ignoring unknown legacy scheme: " + scheme);
            }
            // This is a one-shot compatibility field. Never let it override
            // modern fields on the next startup.
            appearanceData.schemeId = "";
            changed = true;
        }

        if (changed)
            appearanceData.version = 1;
        return changed;
    }

    function finishLoading() {
        root.ready = true;
        if (root.migrateStoredState())
            saveTimer.restart();
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
        path: Quickshell.statePath("appearance.json")
        preload: true
        printErrors: false
        atomicWrites: true
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.finishLoading()
        onLoadFailed: error => {
            if (error !== FileViewError.FileNotFound)
                console.warn("Cannot load appearance settings:", error);
            root.finishLoading();
        }
        onSaveFailed: error => console.warn("Cannot save appearance settings:", error)

        JsonAdapter {
            id: appearanceData
            property int version: 1
            property string schemeId: ""
            property string themeId: "neumorphic"
            property string paletteId: "pastel-relief"
            property string colorMode: "system"
            property string accentId: ""
            property string fontFamily: "SpaceMono Nerd Font"
            property string iconFontFamily: "SpaceMono Nerd Font Propo"
            property real fontScale: 1
            property real radiusScale: 1
            property real spacingScale: 1
            property real motionScale: 1
        }
    }
}
