import "./NiriState.js" as NiriState
import QtQuick
import Quickshell
import Quickshell.Io

WindowManagerBackend {
    id: root

    property var state: NiriState.empty()
    property bool hasWorkspacesSnapshot: false
    property bool hasWindowsSnapshot: false
    property bool connectionRequested: true
    readonly property string socketPath: Quickshell.env("NIRI_SOCKET") || ""
    readonly property bool initialSyncReady: events.connected && actions.connected
        && root.hasWorkspacesSnapshot && root.hasWindowsSnapshot

    function resetConnectionState() {
        root.hasWorkspacesSnapshot = false;
        root.hasWindowsSnapshot = false;
        root.state = NiriState.empty();
        root.publish(NiriState.snapshot(root.state));
    }

    function scheduleReconnect() {
        if (root.socketPath.length > 0)
            reconnect.restart();
        else
            reconnect.stop();
    }

    function invalidateConnection() {
        // Both sockets belong to one IPC session. If either side fails, discard
        // the snapshot and reconnect both sides so availability cannot expose a
        // half-old state.
        root.connectionRequested = false;
        root.resetConnectionState();
        root.scheduleReconnect();
    }

    function receive(line) {
        try {
            const event = JSON.parse(line);
            const hasWorkspacesSnapshot = event.WorkspacesChanged
                && Array.isArray(event.WorkspacesChanged.workspaces);
            const hasWindowsSnapshot = event.WindowsChanged
                && Array.isArray(event.WindowsChanged.windows);

            const next = NiriState.apply(root.state, event);
            if (next === root.state)
                return;

            if (hasWorkspacesSnapshot)
                root.hasWorkspacesSnapshot = true;
            if (hasWindowsSnapshot)
                root.hasWindowsSnapshot = true;
            root.state = next;
            root.publish(NiriState.snapshot(next));
        } catch (error) {
            console.warn("Cannot read Niri event:", error.message);
        }
    }

    function sendAction(action) {
        if (!root.available) {
            console.warn("Niri action unavailable: IPC socket is disconnected");
            return;
        }
        actions.write(JSON.stringify({
            "Action": action
        }) + "\n");
        actions.flush();
    }

    available: root.initialSyncReady
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
        connected: root.connectionRequested && path.length > 0
        onConnectionStateChanged: {
            if (connected) {
                root.resetConnectionState();
                write('"EventStream"\n');
                flush();
            } else {
                if (root.connectionRequested)
                    root.invalidateConnection();
                else
                    root.scheduleReconnect();
            }
        }
        onError: {
            root.invalidateConnection();
        }

        parser: SplitParser {
            onRead: line => {
                return root.receive(line);
            }
        }
    }

    Socket {
        id: actions

        path: root.socketPath
        connected: root.connectionRequested && path.length > 0
        onConnectionStateChanged: {
            // The event socket owns the snapshot handshake. Do not clear a
            // snapshot merely because the action socket finishes connecting
            // slightly later; that would race the initial EventStream reply.
            if (!connected && root.connectionRequested)
                root.invalidateConnection();
            else if (!connected)
                root.scheduleReconnect();
        }
        onError: {
            root.invalidateConnection();
        }

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
            root.connectionRequested = true;
        }
    }
}
