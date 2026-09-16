import "../../services"
import "../../theme"
import "../../ui/IconGlyphs.js" as IconGlyphs
import "../../ui/controls"
import "../audio"
import "../bluetooth"
import "../session"
import "../theme"
import QtQuick

Row {
    id: root

    property var barWindow

    spacing: Theme.spacing.small

    NetworkIndicator {}

    // Bluetooth (with BluetoothPopup)
    BarButton {
        id: btBtn

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
                if (bluetoothLoader.item)
                    bluetoothLoader.item.open();
            } else if (bluetoothLoader.item) {
                bluetoothLoader.item.toggle();
            }
        }

        active: BluetoothService.connectedDevices.length > 0
        onClicked: btBtn.toggleBluetoothMenu()
        onRightClicked: BluetoothService.toggle()

        content: BarText {
            anchors.verticalCenter: parent ? parent.verticalCenter : undefined
            text: {
                if (!BluetoothService.enabled)
                    return "󰂲";

                const count = BluetoothService.connectedDevices.length;
                return count > 0 ? (" " + count) : "";
            }
            color: btBtn.foreground
        }
    }

    Loader {
        id: bluetoothLoader
        active: false
        sourceComponent: Component {
            BluetoothPopup {
                anchorItem: btBtn
                barWindow: root.barWindow
            }
        }
    }

    // Audio (Wireplumber / Pipewire with AudioPopup)
    BarButton {
        id: audioBtn
        urgent: AudioService.outputMuted

        tooltipText: {
            const pct = Math.round(AudioService.outputVolume * 100);
            const desc = AudioService.outputName ? (AudioService.outputName + " // ") : "";
            return desc + (AudioService.outputMuted ? "Muted" : (pct + "%")) + " (Click for menu // Right-click to mute)";
        }
        function toggleAudioMenu() {
            if (!audioLoader.active) {
                audioLoader.active = true;
                if (audioLoader.item)
                    audioLoader.item.open();
            } else if (audioLoader.item) {
                audioLoader.item.toggle();
            }
        }

        onClicked: audioBtn.toggleAudioMenu()
        onRightClicked: AudioService.toggleOutputMute()
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0)
                AudioService.adjustOutputVolume(0.02);
            else if (wheel.angleDelta.y < 0)
                AudioService.adjustOutputVolume(-0.02);
        }

        content: BarText {
            anchors.verticalCenter: parent ? parent.verticalCenter : undefined
            text: {
                const icon = IconGlyphs.volume(AudioService.outputMuted, AudioService.outputVolume);
                const pct = Math.round(AudioService.outputVolume * 100);
                return AudioService.outputMuted ? icon : (icon + " " + pct + "%");
            }
            color: audioBtn.foreground
        }
    }

    Loader {
        id: audioLoader
        active: false
        sourceComponent: Component {
            AudioPopup {
                anchorItem: audioBtn
                barWindow: root.barWindow
            }
        }
    }

    // Theme (with ThemePopup)
    BarButton {
        id: themeBtn

        tooltipText: "主题: " + Theme.displayName
            + "\n" + Theme.palette.displayName + " · " + Theme.resolvedColorMode + " · " + Theme.accentId
            + (ThemeController.canSetColorMode(Theme.resolvedColorMode === "dark" ? "light" : "dark")
                ? "\n点击选择主题 / 右键切换配色明暗" : "\n点击选择主题 / 右键定制配色")
        function toggleThemeMenu() {
            if (!themeLoader.active) {
                themeLoader.active = true;
                if (themeLoader.item)
                    themeLoader.item.open();
            } else if (themeLoader.item) {
                themeLoader.item.toggle();
            }
        }

        onClicked: themeBtn.toggleThemeMenu()
        onRightClicked: {
            if (!ThemeController.toggleColorMode()) {
                themeLoader.active = true;
                if (themeLoader.item) {
                    themeLoader.item.colorsExpanded = true;
                    themeLoader.item.open();
                }
            }
        }
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0)
                ThemeController.nextPalette();
            else if (wheel.angleDelta.y < 0)
                ThemeController.nextAccent();
        }

        content: BarText {
            anchors.verticalCenter: parent ? parent.verticalCenter : undefined
            text: "󰏘"
            color: Theme.colors.accent
        }
    }

    Loader {
        id: themeLoader
        active: false
        sourceComponent: Component {
            ThemePopup {
                anchorItem: themeBtn
                barWindow: root.barWindow
            }
        }
    }

    // Power Button
    BarButton {
        id: powerBtn

        tooltipText: "  Power Manage"
        function togglePowerMenu() {
            if (!powerLoader.active) {
                powerLoader.active = true;
                if (powerLoader.item)
                    powerLoader.item.open();
            } else if (powerLoader.item) {
                powerLoader.item.toggle();
            }
        }

        onClicked: powerBtn.togglePowerMenu()

        content: BarText {
            anchors.verticalCenter: parent ? parent.verticalCenter : undefined
            text: ""
        }
    }

    // Native Quickshell Power Menu
    Loader {
        id: powerLoader
        active: false
        sourceComponent: Component {
            SessionMenu {
                anchorItem: powerBtn
                barWindow: root.barWindow
            }
        }
    }
}
