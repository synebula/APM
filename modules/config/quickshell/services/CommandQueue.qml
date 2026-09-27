import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property var pendingCommands: []
    property var currentCommand: null
    property Process activeProcess: null
    property int generation: 0
    property int activeGeneration: 0
    property bool settled: true
    readonly property bool running: root.activeProcess !== null && root.activeProcess.running
    readonly property var activeCommand: root.currentCommand || []
    signal commandFinished(var command, int exitCode)

    // Keep the in-flight command; coalesce obsolete requests that have not started.
    function replacePending(commands) {
        root.pendingCommands = Array.isArray(commands) ? commands.slice() : [];
        root.runNext();
    }

    function runNext() {
        if (root.activeProcess !== null || root.pendingCommands.length === 0)
            return;

        const next = root.pendingCommands[0];
        root.pendingCommands = root.pendingCommands.slice(1);
        root.currentCommand = next;
        root.settled = false;
        root.generation += 1;
        root.activeGeneration = root.generation;

        const processObject = processComponent.createObject(root, {
            "queueOwner": root,
            "commandGeneration": root.activeGeneration
        });
        if (!processObject) {
            root.settled = true;
            root.currentCommand = null;
            root.commandFinished(next, -1);
            Qt.callLater(root.runNext);
            return;
        }

        root.activeProcess = processObject;
        root.activeProcess.exec(next);
    }

    function finishCurrent(exitCode) {
        const processObject = root.activeProcess;
        if (processObject === null || root.currentCommand === null || root.settled)
            return;

        const command = root.currentCommand;
        root.settled = true;
        processObject.commandSettled = true;
        root.currentCommand = null;
        watchdogTimer.stop();

        // Mark the command settled before stopping the process. A delayed exited
        // signal from this exact object must never settle a later command.
        root.commandFinished(command, exitCode);
        if (processObject.running)
            processObject.running = false;
        else
            root.retireProcess(processObject);
    }

    function handleProcessExited(processObject, commandGeneration, exitCode) {
        if (processObject !== root.activeProcess
                || commandGeneration !== root.activeGeneration
                || processObject.commandSettled)
            return;
        root.finishCurrent(exitCode);
    }

    function handleProcessStopped(processObject, commandGeneration) {
        if (processObject !== root.activeProcess
                || commandGeneration !== root.activeGeneration
                || !processObject.commandSettled)
            return;
        root.retireProcess(processObject);
    }

    function retireProcess(processObject) {
        if (processObject === null || processObject !== root.activeProcess)
            return;

        root.activeProcess = null;
        processObject.queueOwner = null;
        processObject.destroy();
        Qt.callLater(root.runNext);
    }

    property int timeoutMs: 10000

    Timer {
        id: watchdogTimer
        interval: root.timeoutMs
        running: root.running && root.timeoutMs > 0
        repeat: false
        onTriggered: {
            if (root.running && root.currentCommand !== null && !root.settled) {
                console.warn("CommandQueue: process timed out after " + root.timeoutMs + "ms: " + JSON.stringify(root.currentCommand));
                root.finishCurrent(-1);
            }
        }
    }

    Component {
        id: processComponent

        Process {
            id: commandProcess

            property var queueOwner: null
            property int commandGeneration: 0
            property bool commandSettled: false

            onExited: exitCode => {
                if (commandProcess.queueOwner)
                    commandProcess.queueOwner.handleProcessExited(commandProcess, commandProcess.commandGeneration, exitCode);
            }
            onRunningChanged: {
                if (!commandProcess.running && commandProcess.queueOwner)
                    commandProcess.queueOwner.handleProcessStopped(commandProcess, commandProcess.commandGeneration);
            }
        }
    }
}
