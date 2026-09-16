import QtQuick
import Quickshell.Hyprland

WindowManagerBackend {
    id: root

    readonly property var snapshot: ({
            "workspaces": Hyprland.workspaces.values.map(workspace => {
                return ({
                        "workspaceId": String(workspace.id),
                        "name": workspace.name || String(workspace.id),
                        "index": workspace.id,
                        "outputName": workspace.monitor ? workspace.monitor.name : "",
                        "active": workspace.active,
                        "focused": workspace.focused,
                        "urgent": workspace.urgent
                    });
            }),
            "windows": Hyprland.toplevels.values.map(window => {
                return ({
                        "windowId": window.address,
                        "appId": window.lastIpcObject.class || window.lastIpcObject.initialClass || (window.wayland ? window.wayland.appId : ""),
                        "title": window.title,
                        "workspaceId": window.workspace ? String(window.workspace.id) : "",
                        "outputName": window.monitor ? window.monitor.name : "",
                        "focused": window.activated,
                        "urgent": window.urgent
                    });
            })
        })

    function refresh() {
        root.publish(root.snapshot);
    }

    // Lua and legacy dispatch are current Hyprland protocol variants, confined to this backend.
    function dispatch(legacy, lua) {
        Hyprland.dispatch(Hyprland.usingLua ? lua : legacy);
    }

    function windowSelector(windowId) {
        return "address:" + (/^0x/i.test(windowId) ? windowId : "0x" + windowId);
    }

    available: true
    onSnapshotChanged: Qt.callLater(root.refresh)
    Component.onCompleted: root.refresh()
    onSwitchWorkspaceRequested: name => {
        const workspace = Hyprland.workspaces.values.find(item => {
            return item.name === name || String(item.id) === name;
        });
        if (workspace) {
            workspace.activate();
            return;
        }
        const number = Number(name);
        const argument = Number.isFinite(number) ? String(number) : JSON.stringify(name);
        root.dispatch("workspace " + name, "hl.dsp.focus({ workspace = " + argument + " })");
    }
    onFocusWindowRequested: windowId => {
        const selector = root.windowSelector(windowId);
        root.dispatch("focuswindow " + selector, "hl.dsp.focus({ window = " + JSON.stringify(selector) + " })");
    }
    onCloseWindowRequested: windowId => {
        const selector = root.windowSelector(windowId);
        root.dispatch("closewindow " + selector, "hl.dsp.window.close({ window = " + JSON.stringify(selector) + " })");
    }
    onExitSessionRequested: root.dispatch("exit", "hl.dsp.exit()")
}
