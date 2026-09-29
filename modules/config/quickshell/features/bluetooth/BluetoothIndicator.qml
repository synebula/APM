pragma ComponentBehavior: Bound
import QtQuick
import "../../ui/controls"
import "../../services"

BarButton {
    id: root
    property var barWindow: null
    readonly property BluetoothPopup popup: bluetoothLoader.item as BluetoothPopup
    objectName: "BluetoothIndicator"

    visible: BluetoothService.available
    tooltipText: {
        if (!BluetoothService.enabled)
            return "Bluetooth: Disabled (Right-click to enable)";

        const count = BluetoothService.connectedDevices.length;
        return "Bluetooth: " + (count > 0 ? (count + " connected") : "On") + " (Click for devices)";
    }
    function toggleBluetoothMenu() {
        if (!bluetoothLoader.active) {
            bluetoothLoader.active = true;
            if (root.popup)
                root.popup.open();
        } else if (root.popup) {
            root.popup.toggle();
        }
    }

    active: BluetoothService.connectedDevices.length > 0
    onClicked: root.toggleBluetoothMenu()
    onRightClicked: BluetoothService.toggle()

    content: BarText {
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined
        text: {
            if (!BluetoothService.enabled)
                return "󰂲";

            const count = BluetoothService.connectedDevices.length;
            return count > 0 ? (" " + count) : "";
        }
        color: root.foreground
    }

    Loader {
        id: bluetoothLoader
        active: false
        sourceComponent: Component {
            BluetoothPopup {
                anchorItem: root
                barWindow: root.barWindow
            }
        }
    }

}
