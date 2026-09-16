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
    readonly property var userOverrides: appearanceData.userOverrides
    readonly property string fontFamily: appearanceData.fontFamily
    readonly property string iconFontFamily: appearanceData.iconFontFamily
    readonly property real fontScale: appearanceData.fontScale
    readonly property real radiusScale: appearanceData.radiusScale
    readonly property real spacingScale: appearanceData.spacingScale
    readonly property real motionScale: appearanceData.motionScale
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
            property string themeId: "neumorphic"
            property string paletteId: "pastel-relief"
            property string colorMode: "system"
            property string accentId: ""
            property var userOverrides: ({})
            property string fontFamily: "SpaceMono Nerd Font"
            property string iconFontFamily: "SpaceMono Nerd Font Propo"
            property real fontScale: 1
            property real radiusScale: 1
            property real spacingScale: 1
            property real motionScale: 1
        }
    }
}
