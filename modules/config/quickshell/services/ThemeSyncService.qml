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

    Component.onCompleted: {
        debounceTimer.restart();
    }

    function syncNow() {
        if (!root.enabled || root.testMode)
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
        function onPaletteVariantChanged() { debounceTimer.restart(); }
        function onDefinitionChanged() { debounceTimer.restart(); }
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
