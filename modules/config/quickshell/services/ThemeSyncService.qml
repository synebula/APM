pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

import "../theme"

Singleton {
    id: root

    property bool enabled: true
    readonly property bool testMode: Quickshell.env("APM_QUICKSHELL_TEST_MODE") === "1"
    readonly property string scriptPath: decodeURIComponent(Qt.resolvedUrl("../scripts/sync-desktop-theme.sh").toString().replace(/^file:\/\//, ""))
    readonly property bool syncing: syncQueue.activeProcess !== null || syncQueue.pendingCommands.length > 0
    property int lastExitCode: 0
    signal syncFinished(int exitCode)

    Component.onCompleted: {
        debounceTimer.restart();
    }

    function syncNow(): bool {
        debounceTimer.stop();
        if (!root.enabled || root.testMode)
            return false;
        syncQueue.replacePending([[
            "bash", root.scriptPath,
            "--mode", Theme.resolvedColorMode,
            "--palette", Theme.palette.paletteId,
            "--accent", Theme.colors.accent.toString(),
            "--surface", Theme.colors.surface.toString(),
            "--outline", Theme.colors.outline.toString()
        ]]);
        return true;
    }

    Timer {
        id: debounceTimer
        interval: 350
        repeat: false
        onTriggered: root.syncNow()
    }

    Connections {
        target: Theme
        function onResolvedColorModeChanged() { debounceTimer.restart(); }
        function onPaletteChanged() { debounceTimer.restart(); }
        function onPaletteVariantChanged() { debounceTimer.restart(); }
        function onDefinitionChanged() { debounceTimer.restart(); }
        function onAccentIdChanged() { debounceTimer.restart(); }
    }

    CommandQueue {
        id: syncQueue
        onCommandFinished: (command, exitCode) => {
            root.lastExitCode = exitCode;
            if (exitCode !== 0)
                console.warn("ThemeSyncService: desktop synchronization failed (exit " + exitCode + ")");
            root.syncFinished(exitCode);
        }
    }

    IpcHandler {
        target: "theme-sync"
        function sync(): bool {
            return root.syncNow();
        }
    }
}
