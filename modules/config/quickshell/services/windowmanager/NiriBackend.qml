import "./NiriState.js" as NiriState
import QtQuick
import Quickshell
import Quickshell.Io

WindowManagerBackend {
    id: root

    property var state: NiriState.empty()
    readonly property string socketPath: Quickshell.env("NIRI_SOCKET") || ""

    function receive(line) {
        try {
            const next = NiriState.apply(root.state, JSON.parse(line));
            if (next === root.state)
                return;

            root.state = next;
            root.publish(NiriState.snapshot(next));
        } catch (error) {
            console.warn("Cannot read Niri event:", error.message);
        }
    }

    function sendAction(action) {
        if (!actions.connected) {
            console.warn("Niri action unavailable: IPC socket is disconnected");
            return;
        }
        actions.write(JSON.stringify({
            "Action": action
        }) + "\n");
        actions.flush();
    }

    available: events.connected && actions.connected
    onSwitchWorkspaceRequested: name => {
        return root.sendAction({
            "FocusWorkspace": {
                "reference": NiriState.workspaceReference(root.state, name)
            }
        });
    }
    onFocusWindowRequested: windowId => {
        return root.sendAction({
            "FocusWindow": {
                "id": Number(windowId)
            }
        });
    }
    onCloseWindowRequested: windowId => {
        return root.sendAction({
            "CloseWindow": {
                "id": Number(windowId)
            }
        });
    }
    onExitSessionRequested: root.sendAction({
        "Quit": {
            "skip_confirmation": true
        }
    })

    Socket {
        id: events

        path: root.socketPath
        connected: path.length > 0
        onConnectionStateChanged: {
            if (connected) {
                root.state = NiriState.empty();
                write('"EventStream"\n');
                flush();
            } else {
                reconnect.restart();
            }
        }
        onError: reconnect.restart()

        parser: SplitParser {
            onRead: line => {
                return root.receive(line);
            }
        }
    }

    Socket {
        id: actions

        path: root.socketPath
        connected: path.length > 0
        onConnectionStateChanged: {
            if (!connected)
                reconnect.restart();
        }
        onError: reconnect.restart()

        parser: SplitParser {
            onRead: line => {
                try {
                    const reply = JSON.parse(line);
                    if (reply.Err)
                        console.warn("Niri action failed:", reply.Err);
                } catch (error) {
                    console.warn("Cannot read Niri reply:", error.message);
                }
            }
        }
    }

    Timer {
        id: reconnect

        interval: 1000
        onTriggered: {
            if (!root.socketPath)
                return;

            if (!events.connected)
                events.connected = true;

            if (!actions.connected)
                actions.connected = true;
        }
    }
}
