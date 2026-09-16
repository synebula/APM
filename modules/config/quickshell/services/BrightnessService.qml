pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool hasBrightnessctl: false
    property bool hasDdcutil: false
    readonly property bool available: root.hasBrightnessctl || root.ddcMonitors.length > 0
    property real brightness: 0.8
    property var ddcMonitors: []

    function setBrightness(value: real) {
        if (!Number.isFinite(value))
            return;

        root.brightness = Math.max(0.05, Math.min(1, value));
        syncTimer.restart();
    }

    function adjustBrightness(delta: real) {
        root.setBrightness(root.brightness + delta);
    }

    function syncBrightness() {
        const percent = Math.round(root.brightness * 100);
        const commands = [];
        if (root.hasBrightnessctl)
            commands.push(["brightnessctl", "set", percent + "%", "--quiet"]);

        for (const monitor of root.ddcMonitors)
            commands.push(["ddcutil", "-b", monitor.busNumber, "setvcp", "10", String(percent)]);
        writer.replacePending(commands);
    }

    Process {
        command: ["which", "brightnessctl"]
        running: true
        onExited: exitCode => {
            return root.hasBrightnessctl = exitCode === 0;
        }
    }

    Process {
        command: ["which", "ddcutil"]
        running: true
        onExited: exitCode => {
            root.hasDdcutil = exitCode === 0;
            if (root.hasDdcutil)
                detect.running = true;
        }
    }

    Process {
        id: detect

        command: ["ddcutil", "detect", "--brief"]

        stdout: StdioCollector {
            onStreamFinished: {
                const monitors = [];
                for (const block of text.split(/\n\s*\n/)) {
                    const bus = block.match(/I2C bus:\s*\/dev\/i2c-([0-9]+)/);
                    const connector = block.match(/DRM connector:\s*(?:card[0-9]+-)?(\S+)/);
                    if (block.trim().startsWith("Display ") && bus && connector)
                        monitors.push({
                            "name": connector[1],
                            "busNumber": bus[1]
                        });
                }
                root.ddcMonitors = monitors;
            }
        }
    }

    Timer {
        id: syncTimer

        interval: 300
        onTriggered: root.syncBrightness()
    }

    CommandQueue {
        id: writer

        onCommandFinished: (command, exitCode) => {
            if (exitCode !== 0)
                console.warn("Brightness command failed:", command[0], exitCode);
        }
    }
}
