pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool available: adapter !== null
    readonly property bool enabled: available && adapter.enabled
    readonly property bool discovering: adapter ? adapter.discovering : false
    readonly property var rawDevices: Bluetooth.devices ? Bluetooth.devices.values : []
    property int _deviceStateRevision: 0

    Instantiator {
        model: root.rawDevices
        delegate: QtObject {
            required property var modelData
            readonly property bool connected: modelData ? modelData.connected : false
            readonly property bool paired: modelData ? modelData.paired : false
            readonly property bool bonded: modelData ? modelData.bonded : false
            readonly property bool trusted: modelData ? modelData.trusted : false
            onConnectedChanged: root._deviceStateRevision++
            onPairedChanged: root._deviceStateRevision++
            onBondedChanged: root._deviceStateRevision++
            onTrustedChanged: root._deviceStateRevision++
        }
    }

    readonly property var devices: {
        const _ = root._deviceStateRevision;
        const list = [];
        for (let i = 0; i < root.rawDevices.length; i++) {
            const d = root.rawDevices[i];
            if (d && (d.name || d.address))
                list.push(d);
        }
        return list.sort((a, b) => {
            if (a.connected !== b.connected)
                return a.connected ? -1 : 1;

            if (a.paired !== b.paired)
                return a.paired ? -1 : 1;

            return (a.name || a.address || "").localeCompare(b.name || b.address || "");
        });
    }
    readonly property var connectedDevices: root.devices.filter(d => {
        return d.connected;
    })
    readonly property var pairedDevices: root.devices.filter(d => {
        return !d.connected && (d.paired || d.bonded || d.trusted);
    })
    readonly property var availableDevices: root.devices.filter(d => {
        return !d.connected && !d.paired && !d.bonded && !d.trusted;
    })

    function toggle() {
        if (root.adapter)
            root.adapter.enabled = !root.adapter.enabled;
    }

    function setEnabled(enabled) {
        if (root.adapter)
            root.adapter.enabled = enabled;
    }

    function toggleDiscovery() {
        if (root.adapter)
            root.adapter.discovering = !root.adapter.discovering;
    }

    function connectDevice(dev) {
        if (dev && !dev.connected)
            dev.connect();
    }

    function disconnectDevice(dev) {
        if (dev && dev.connected)
            dev.disconnect();
    }

    function deviceIcon(dev) {
        if (!dev)
            return "";

        const icon = (dev.icon || "").toLowerCase();
        if (icon.includes("headset") || icon.includes("headphone"))
            return "󰋋";

        if (icon.includes("audio") || icon.includes("speaker"))
            return "󰓃";

        if (icon.includes("mouse"))
            return "󰍽";

        if (icon.includes("keyboard"))
            return "󰌌";

        if (icon.includes("phone"))
            return "󰄡";

        return "";
    }
}
