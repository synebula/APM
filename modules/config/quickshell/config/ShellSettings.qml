pragma Singleton
import Quickshell

Singleton {
    id: root
    readonly property var workspacesByOutput: ({
            "HDMI-A-1": ["1", "2", "3", "4", "5"],
            "HDMI-A-2": ["6", "7", "8", "9", "10"]
        })
    readonly property list<string> defaultWorkspaces: ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    readonly property list<string> taskbarExcludedAppPatterns: []
    readonly property int notificationTimeout: 5000
    readonly property int notificationHistoryLimit: 50
    readonly property int notificationToastLimit: 4
    readonly property bool toastsOnFocusedScreenOnly: true

    function workspacesForOutput(name) {
        return root.workspacesByOutput[name] || root.defaultWorkspaces;
    }

    function showInTaskbar(appId) {
        return !root.taskbarExcludedAppPatterns.some(pattern => new RegExp(pattern, "i").test(appId));
    }
}
