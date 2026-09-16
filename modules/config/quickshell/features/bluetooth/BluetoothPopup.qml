import "../../services"
import "../../theme"
import "../../ui/containers"
import "../../ui/controls"
import QtQuick
import QtQuick.Layouts

PopupPanel {
    id: root

    contentWidth: Math.round(300 * Theme.controlScale)
    contentHeight: sections.implicitHeight + Theme.components.popup.padding * 2
    alignRight: true

    Column {
        id: sections

        anchors.centerIn: parent
        width: parent.width - Theme.components.popup.padding * 2
        spacing: Theme.spacing.large

        SectionHeader {
            width: parent.width
            title: "蓝牙"
            subtitle: BluetoothService.available ? (BluetoothService.enabled ? "已连接 " + BluetoothService.connectedDevices.length + " 个设备" : "蓝牙已关闭") : "未检测到蓝牙适配器"
            glyph: ""

            IconButton {
                glyph: "󰑐"
                tooltipText: BluetoothService.discovering ? "停止扫描" : "扫描设备"
                enabled: BluetoothService.enabled
                checked: BluetoothService.discovering
                onClicked: BluetoothService.toggleDiscovery()
            }

            ToggleSwitch {
                enabled: BluetoothService.available
                checked: BluetoothService.enabled
                onToggled: BluetoothService.setEnabled(checked)
            }
        }

        Divider {
            width: parent.width
        }

        Repeater {
            model: [
                {
                    "title": "已连接",
                    "devices": BluetoothService.connectedDevices
                },
                {
                    "title": "已配对",
                    "devices": BluetoothService.pairedDevices
                },
                {
                    "title": "附近设备",
                    "devices": BluetoothService.availableDevices
                }
            ]

            delegate: Column {
                id: section

                required property var modelData

                width: sections.width
                spacing: Theme.spacing.small
                visible: BluetoothService.enabled && modelData.devices.length > 0

                TextLabel {
                    text: section.modelData.title
                    font: Theme.typography.caption
                    color: Theme.colors.textSecondary
                }

                Repeater {
                    model: section.modelData.devices

                    delegate: ActionRow {
                        id: deviceRow

                        required property var modelData

                        width: sections.width
                        text: modelData.name || modelData.address
                        glyph: BluetoothService.deviceIcon(modelData)
                        selected: modelData.connected
                        trailingText: modelData.batteryAvailable ? Math.round(modelData.battery * 100) + "%" : ""
                        onClicked: {
                            if (modelData.connected)
                                BluetoothService.disconnectDevice(modelData);
                            else
                                BluetoothService.connectDevice(modelData);
                        }

                        IconGlyph {
                            text: deviceRow.modelData.connected ? "󰅖" : "󰄬"
                            color: deviceRow.modelData.connected ? Theme.colors.danger : Theme.colors.textSecondary
                        }
                    }
                }
            }
        }

        TextLabel {
            width: parent.width
            visible: BluetoothService.enabled && BluetoothService.devices.length === 0
            text: BluetoothService.discovering ? "正在查找附近设备…" : "暂无设备，点击扫描开始查找"
            wrapMode: Text.Wrap
            color: Theme.colors.textSecondary
        }
    }
}
