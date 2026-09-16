import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property bool isOpen: false
    property string mode: "applications"
    property string query: ""
    property int selectedIndex: 0
    readonly property var providers: ({
            "applications": applicationProvider,
            "commands": commandProvider
        })
    readonly property var provider: root.providers[root.mode]
    property int refreshIndex: 0

    function refresh() {
        root.refreshIndex++;
    }

    readonly property var results: {
        const _ = root.refreshIndex;
        const h = history.entries(root.mode);
        return root.provider ? root.provider.search(root.query, h) : [];
    }

    signal opened

    function open(mode) {
        if (!root.providers[mode])
            return;

        root.mode = mode;
        root.query = "";
        root.selectedIndex = 0;
        root.refresh();
        root.isOpen = true;
        root.opened();
    }

    function toggle(mode) {
        if (root.isOpen && root.mode === mode)
            root.close();
        else
            root.open(mode);
    }

    function close() {
        root.isOpen = false;
    }

    function selectNext(delta) {
        if (!root.results.length)
            return;

        root.selectedIndex = (root.selectedIndex + delta + root.results.length) % root.results.length;
    }

    function launch(inTerminal) {
        let provider = root.provider;
        let result = root.results[root.selectedIndex];
        if (!result && root.query.trim()) {
            provider = commandProvider;
            result = commandProvider.result(root.query.trim());
        }
        if (!result)
            return;

        history.record(provider.mode, result.key);
        root.close();
        provider.launch(result, inTerminal);
    }

    onResultsChanged: root.selectedIndex = 0

    ApplicationProvider {
        id: applicationProvider
    }

    CommandProvider {
        id: commandProvider
    }

    LaunchHistoryStore {
        id: history
    }

    Connections {
        target: history
        function onReadyChanged() { root.refresh(); }
        function onApplicationsChanged() { root.refresh(); }
        function onCommandsChanged() { root.refresh(); }
    }

    Connections {
        target: applicationProvider
        function onEntriesChanged() { root.refresh(); }
    }

    IpcHandler {
        function toggle() {
            root.toggle("applications");
        }

        function toggleRun() {
            root.toggle("commands");
        }

        function open() {
            root.open("applications");
        }

        function openRun() {
            root.open("commands");
        }

        function close() {
            root.close();
        }

        target: "launcher"
    }
}
