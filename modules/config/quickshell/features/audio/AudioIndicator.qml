pragma ComponentBehavior: Bound
import QtQuick
import "../../ui/controls"
import "../../services"
import "../../config"
import "../../ui/IconGlyphs.js" as IconGlyphs

BarButton {
    id: root
    property var barWindow: null
    readonly property AudioPopup popup: audioLoader.item as AudioPopup
    objectName: "AudioIndicator"
    urgent: AudioService.outputMuted

    tooltipText: {
        const pct = Math.round(AudioService.outputVolume * 100);
        const desc = AudioService.outputName ? (AudioService.outputName + " // ") : "";
        return desc + (AudioService.outputMuted ? "Muted" : (pct + "%")) + " (Click for menu // Right-click to mute)";
    }
    function toggleAudioMenu() {
        if (!audioLoader.active) {
            audioLoader.active = true;
            if (root.popup)
                root.popup.open();
        } else if (root.popup) {
            root.popup.toggle();
        }
    }

    onClicked: root.toggleAudioMenu()
    onRightClicked: AudioService.toggleOutputMute()
    onWheel: wheel => {
        if (wheel.angleDelta.y > 0)
            AudioService.adjustOutputVolume(ShellSettings.volumeStep);
        else if (wheel.angleDelta.y < 0)
            AudioService.adjustOutputVolume(-ShellSettings.volumeStep);
    }

    content: BarText {
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined
        text: {
            const icon = IconGlyphs.volume(AudioService.outputMuted, AudioService.outputVolume);
            const pct = Math.round(AudioService.outputVolume * 100);
            return AudioService.outputMuted ? icon : (icon + " " + pct + "%");
        }
        color: root.foreground
    }

    Loader {
        id: audioLoader
        active: false
        sourceComponent: Component {
            AudioPopup {
                anchorItem: root
                barWindow: root.barWindow
            }
        }
    }

}
