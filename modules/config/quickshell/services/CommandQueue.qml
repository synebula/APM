import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property var pendingCommands: []
    readonly property bool running: process.running
    readonly property list<string> activeCommand: process.command
    signal commandFinished(var command, int exitCode)

    // Keep the in-flight command; coalesce obsolete requests that have not started.
    function replacePending(commands) {
        root.pendingCommands = commands.slice();
        root.runNext();
    }

    function runNext() {
        if (process.running || root.pendingCommands.length === 0)
            return;
        const next = root.pendingCommands[0];
        root.pendingCommands = root.pendingCommands.slice(1);
        process.exec(next);
    }

    property int timeoutMs: 10000

    Timer {
        id: watchdogTimer
        interval: root.timeoutMs
        running: process.running && root.timeoutMs > 0
        repeat: false
        onTriggered: {
            if (process.running) {
                console.warn("CommandQueue: process timed out after " + root.timeoutMs + "ms: " + JSON.stringify(process.command));
                process.running = false;
            }
        }
    }

    Process {
        id: process
        onExited: exitCode => {
            root.commandFinished(process.command, exitCode);
            Qt.callLater(root.runNext);
        }
    }
}
