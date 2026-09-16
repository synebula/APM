import QtQuick
import Quickshell

Scope {
    id: root

    property bool available: false
    property list<WindowInfo> windows: []
    property list<WorkspaceInfo> workspaces: []
    readonly property WindowInfo activeWindow: root.windows.find(window => window.focused) || null
    readonly property WorkspaceInfo focusedWorkspace: root.workspaces.find(workspace => workspace.focused) || null

    signal switchWorkspaceRequested(string name)
    signal focusWindowRequested(string windowId)
    signal closeWindowRequested(string windowId)
    signal exitSessionRequested

    // Preserve object identity so a title/urgency update also refreshes existing delegates.
    function reconcile(current, snapshots, factory, key) {
        const next = snapshots.map(snapshot => {
            const record = current.find(item => item[key] === snapshot[key]) || factory.createObject(root);
            for (const field of Object.keys(snapshot))
                record[field] = snapshot[field];
            return record;
        });
        for (const record of current) {
            if (!next.includes(record))
                record.destroy();
        }
        return next;
    }

    function publish(snapshot) {
        root.workspaces = root.reconcile(root.workspaces, snapshot.workspaces, workspaceFactory, "workspaceId");
        root.windows = root.reconcile(root.windows, snapshot.windows, windowFactory, "windowId");
    }

    Component {
        id: windowFactory
        WindowInfo {}
    }
    Component {
        id: workspaceFactory
        WorkspaceInfo {}
    }
}
