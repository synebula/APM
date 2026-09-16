import "../features/launcher"
import "../features/launcher/LauncherSearch.js" as LauncherSearch
import QtQuick
import Quickshell
import Quickshell.Io

TestSuite {
    id: root

    property var savedHistory: ({})

    function test_historyQueuesUsesDuringLoadAndPersistsCounts() {
        tryVerify(() => {
            return history.ready;
        });
        history.record("applications", "editor");
        compare(history.applications.editor.count, 3);
        tryVerify(() => {
            return root.savedHistory.applications && root.savedHistory.applications.editor.count === 3;
        });
        verify(root.savedHistory.applications.editor.lastUsed > 0);
        verify(!root.savedHistory.drun);
    }

    function test_rankingCombinesSearchAndUsageWithoutDuplicatingEntries() {
        const entries = [
            {
                "key": "editor",
                "label": "Editor",
                "searchTerms": ["Editor", "code"]
            },
            {
                "key": "terminal",
                "label": "Terminal",
                "searchTerms": ["Terminal", "shell"]
            }
        ];
        const usage = {
            "terminal": {
                "count": 5,
                "lastUsed": 0
            }
        };
        compare(LauncherSearch.rank(entries, "", usage)[0].key, "terminal");
        compare(LauncherSearch.rank(entries, "code", usage)[0].key, "editor");
        compare(LauncherSearch.rank(entries, "missing", usage).length, 0);
    }

    function test_commandArgumentsRemainIntact() {
        const result = commands.search("printf hello | cat", {});
        compare(result[0].key, "printf hello | cat");
        compare(result.filter(entry => {
            return entry.key === "printf hello | cat";
        }).length, 1);
    }

    name: "Launcher"

    LaunchHistoryStore {
        id: history

        path: Quickshell.statePath("history-test-" + Date.now() + ".json")
        legacyImportEnabled: false
        Component.onCompleted: {
            record("applications", "editor");
            record("applications", "editor");
        }
    }

    FileView {
        id: saved

        path: history.path
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.savedHistory = JSON.parse(text())
    }

    CommandProvider {
        id: commands
    }
}
