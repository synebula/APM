import QtQuick
import Quickshell

Scope {
    id: root

    property bool visible: false
    property int duration: 0
    property real remaining: 0
    property real deadline: 0
    property var pauseOwners: []
    readonly property bool paused: root.pauseOwners.length > 0
    readonly property real progress: root.duration > 0 ? Math.max(0, root.remaining / root.duration) : 1

    signal expired

    function show(milliseconds) {
        root.duration = Math.max(0, milliseconds);
        root.remaining = root.duration;
        root.deadline = Date.now() + root.remaining;
        root.visible = true;
    }

    function hide() {
        root.visible = false;
    }

    function setPaused(owner, paused) {
        const owners = root.pauseOwners.filter(item => {
            return item !== owner;
        });
        if (paused)
            owners.push(owner);

        const wasPaused = root.paused;
        if (!wasPaused && owners.length > 0 && root.visible && root.duration > 0)
            root.remaining = Math.max(0, root.deadline - Date.now());

        root.pauseOwners = owners;
        if (wasPaused && !root.paused)
            root.deadline = Date.now() + root.remaining;
    }

    Timer {
        interval: 50
        repeat: true
        running: root.visible && !root.paused && root.duration > 0
        onTriggered: {
            root.remaining = Math.max(0, root.deadline - Date.now());
            if (root.remaining > 0)
                return;

            root.visible = false;
            root.expired();
        }
    }
}
