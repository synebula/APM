import "../../ui/controls"
import QtQuick
import Quickshell.Networking

BarButton {
    tooltipText: {
        for (let i = 0; i < Networking.devices.values.length; i++) {
            const device = Networking.devices.values[i];
            if (device.connected)
                return (device.type === DeviceType.Wifi ? "Wi-Fi: " : "Ethernet: ") + (device.name || "") + " (" + (device.address || "") + ")";
        }
        return "Network: Disconnected";
    }

    content: BarText {
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined
        text: {
            let hasConnected = false;
            let isWifi = false;
            for (let i = 0; i < Networking.devices.values.length; i++) {
                const device = Networking.devices.values[i];
                if (device.connected) {
                    hasConnected = true;
                    isWifi = device.type === DeviceType.Wifi;
                    break;
                }
            }
            if (!hasConnected)
                return "";
            return isWifi ? "󰤨" : "󱘖";
        }
    }
}
