import "../../services"
import "../../theme"
import "../../ui/containers"
import "../../ui/controls"
import QtQuick

PopupPanel {
    id: root

    contentWidth: Math.round(280 * Theme.controlScale)
    contentHeight: channels.implicitHeight + Theme.components.popup.padding * 2
    alignRight: true

    Column {
        id: channels

        anchors.centerIn: parent
        width: parent.width - Theme.components.popup.padding * 2
        spacing: Theme.spacing.large

        AudioChannelSection {
            width: parent.width
            title: "音量输出"
            node: AudioService.defaultOutput
            devices: AudioService.outputDevices
            onDeviceSelected: device => {
                return AudioService.setDefaultOutput(device);
            }
        }

        Divider {
            width: parent.width
            visible: AudioService.inputDevices.length > 0
        }

        AudioChannelSection {
            width: parent.width
            visible: AudioService.inputDevices.length > 0
            title: "麦克风输入"
            node: AudioService.defaultInput
            devices: AudioService.inputDevices
            onDeviceSelected: device => {
                return AudioService.setDefaultInput(device);
            }
        }
    }
}
