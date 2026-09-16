pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property string systemMode: "light"
    property string source: "fallback"
    readonly property bool available: root.source !== "fallback"

    function handleResult(text: string) {
        const line = text.trim();
        if (!line)
            return;
        const parts = line.split(":");
        if (parts.length === 2) {
            root.source = parts[0];
            root.systemMode = parts[1] === "dark" ? "dark" : "light";
        } else {
            root.systemMode = line.toLowerCase().includes("dark") ? "dark" : "light";
        }
    }

    Process {
        id: probe
        command: [
            "sh", "-c",
            "if command -v busctl >/dev/null 2>&1; then out=$(busctl --user call org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop org.freedesktop.portal.Settings Read \"(ss)\" \"org.freedesktop.appearance\" \"color-scheme\" 2>/dev/null); if [ $? -eq 0 ] && [ -n \"$out\" ]; then if echo \"$out\" | grep -q \"uint32 1\"; then echo \"portal:dark\"; exit 0; else echo \"portal:light\"; exit 0; fi; fi; fi; if command -v gsettings >/dev/null 2>&1; then out=$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null); if [ $? -eq 0 ] && [ -n \"$out\" ]; then if echo \"$out\" | grep -q \"dark\"; then echo \"gsettings:dark\"; exit 0; else echo \"gsettings:light\"; exit 0; fi; fi; fi; if command -v darkman >/dev/null 2>&1; then out=$(darkman get 2>/dev/null); if [ $? -eq 0 ] && [ -n \"$out\" ]; then if echo \"$out\" | grep -q \"dark\"; then echo \"darkman:dark\"; exit 0; else echo \"darkman:light\"; exit 0; fi; fi; fi; echo \"fallback:light\""
        ]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root.handleResult(text)
        }
    }

    Timer {
        interval: 30000
        repeat: true
        running: true
        onTriggered: probe.running = true
    }
}
