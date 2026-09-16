pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string systemMode: "light"

    function parseMode(value: string): string {
        const normalized = value.trim().toLowerCase();
        return normalized.includes("dark") ? "dark" : "light";
    }

    Process {
        id: probe
        command: ["sh", "-c", "if command -v gsettings >/dev/null 2>&1; then gsettings get org.gnome.desktop.interface color-scheme; elif command -v darkman >/dev/null 2>&1; then darkman get; else echo light; fi"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root.systemMode = root.parseMode(text)
        }
    }

    Timer {
        interval: 30000
        repeat: true
        running: true
        onTriggered: probe.running = true
    }
}
