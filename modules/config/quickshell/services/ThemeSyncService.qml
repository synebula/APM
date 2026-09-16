pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

import "../theme"

Singleton {
    id: root

    property bool enabled: true
    readonly property string scriptPath: Qt.resolvedUrl("../scripts/sync-desktop-theme.sh").toString().replace(/^file:\/\//, "")

    function syncNow() {
        if (!root.enabled)
            return;
        syncProcess.exec([
            "bash", root.scriptPath,
            "--mode", Theme.resolvedColorMode,
            "--palette", Theme.palette.paletteId,
            "--accent", Theme.colors.accent.toString(),
            "--surface", Theme.colors.surface.toString(),
            "--outline", Theme.colors.outline.toString()
        ]);
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
        function onAccentIdChanged() { debounceTimer.restart(); }
    }

    Process {
        id: syncProcess
    }

    IpcHandler {
        target: "theme-sync"
        function sync(): bool {
            root.syncNow();
            return true;
        }
    }
}
