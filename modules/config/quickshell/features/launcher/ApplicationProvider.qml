import QtQuick
import "./LauncherSearch.js" as LauncherSearch
import Quickshell

Scope {
    id: root

    readonly property string mode: "applications"
    readonly property string placeholder: "搜索应用"
    readonly property string glyph: "󰍉"
    property var entries: []

    function updateEntries() {
        const raw = DesktopEntries.applications.values;
        root.entries = raw.filter(entry => {
            return !entry.noDisplay && entry.name && entry.name.trim().length > 0;
        });
    }

    Component.onCompleted: updateEntries()

    Connections {
        target: DesktopEntries
        function onApplicationsChanged() {
            root.updateEntries();
        }
    }

    function search(query, history) {
        const candidates = root.entries.map(entry => {
            return ({
                    "key": entry.id,
                    "label": entry.name,
                    "description": entry.genericName || entry.comment,
                    "icon": entry.icon,
                    "entry": entry,
                    "searchTerms": [entry.name, entry.id, entry.genericName || "", entry.comment || ""]
                });
        });
        return LauncherSearch.rank(candidates, query, history);
    }

    function launch(result, inTerminal) {
        result.entry.execute();
    }
}
