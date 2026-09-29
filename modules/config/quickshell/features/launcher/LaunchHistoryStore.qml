pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property string path: Quickshell.statePath("launch-history.json")
    property bool ready: false
    property var pendingUses: []
    readonly property var applications: historyData.applications
    readonly property var commands: historyData.commands

    function entries(mode) {
        return mode === "applications" ? root.applications : root.commands;
    }

    function record(mode, key) {
        if (!key || !["applications", "commands"].includes(mode))
            return;
        if (!root.ready) {
            root.pendingUses = root.pendingUses.concat([
                {
                    mode: mode,
                    key: key
                }
            ]);
            return;
        }

        const entries = Object.assign({}, root.entries(mode));
        const previous = entries[key];
        entries[key] = {
            count: (previous ? (previous.count || 0) : 0) + 1,
            lastUsed: Date.now()
        };
        historyData[mode] = entries;
        saveTimer.restart();
    }

    function finishLoading() {
        root.ready = true;

        const pending = root.pendingUses;
        root.pendingUses = [];
        for (const usage of pending)
            root.record(usage.mode, usage.key);
    }

    Timer {
        id: saveTimer
        interval: 120
        onTriggered: file.writeAdapter()
    }

    FileView {
        id: file
        path: root.path
        preload: true
        printErrors: false
        atomicWrites: true
        onLoaded: root.finishLoading()
        onLoadFailed: error => {
            if (error !== FileViewError.FileNotFound)
                console.warn("Cannot load launcher history:", error);
            root.finishLoading();
        }
        onSaveFailed: error => console.warn("Cannot save launcher history:", error)
        JsonAdapter {
            id: historyData
            property var applications: ({})
            property var commands: ({})
        }
    }
}
