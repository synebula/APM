import "../../services"
import "../../theme"
import "../../ui/IconGlyphs.js" as IconGlyphs
import "../../ui/controls"
import "../../ui/effects"
import "../audio/AudioPresentation.js" as AudioPresentation
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: root

    property string kind: "volume"
    property bool initialized: false
    property bool isOpen: false
    readonly property bool muted: root.kind === "volume" && AudioService.outputMuted
    readonly property real value: root.kind === "volume" ? AudioService.outputVolume : BrightnessService.brightness
    readonly property string glyph: root.kind === "brightness" ? "󰃠" : (root.muted ? "󰝟" : (AudioPresentation.deviceGlyph(AudioService.defaultOutput) === "󰋋" ? "󰋋" : IconGlyphs.volume(false, root.value)))

    function show(kind) {
        root.kind = kind;
        root.isOpen = true;
        hideTimer.restart();
    }

    screen: WindowManagerService.focusedScreen
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-osd"
    exclusionMode: ExclusionMode.Ignore
    exclusiveZone: 0
    anchors.bottom: true
    margins.bottom: 64 * Theme.spacingScale
    implicitWidth: 260 * Theme.controlScale
    implicitHeight: 52 * Theme.controlScale
    color: "transparent"
    visible: root.isOpen || card.opacity > 0

    Timer {
        interval: 1200
        running: true
        onTriggered: root.initialized = true
    }

    Timer {
        id: hideTimer

        interval: 1800
        onTriggered: root.isOpen = false
    }

    Connections {
        function onOutputVolumeChanged() {
            if (root.initialized)
                root.show("volume");
        }

        function onOutputMutedChanged() {
            if (root.initialized)
                root.show("volume");
        }

        target: AudioService
    }

    Connections {
        function onBrightnessChanged() {
            if (root.initialized)
                root.show("brightness");
        }

        target: BrightnessService
    }

    IpcHandler {
        function showVolume() {
            root.show("volume");
        }

        function showBrightness() {
            root.show("brightness");
        }

        target: "osd"
    }

    SurfaceFrame {
        id: card

        anchors.fill: parent
        fill: Theme.colors.surface
        radius: Theme.shape.roundRadius
        opacity: root.isOpen ? 1 : 0
        scale: root.isOpen ? 1 : 0.94

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Theme.spacing.extraLarge
            anchors.rightMargin: Theme.spacing.extraLarge
            spacing: Theme.spacing.large

            IconGlyph {
                Layout.alignment: Qt.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                Layout.preferredWidth: 28 * Theme.controlScale
                text: root.glyph
                font.pixelSize: Theme.typography.headingSize
                color: root.muted ? Theme.colors.danger : Theme.colors.accent
            }

            ProgressBar {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                value: root.value
                progressColor: root.muted ? Theme.colors.danger : Theme.colors.accent
            }

            TextLabel {
                Layout.alignment: Qt.AlignVCenter
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignRight
                Layout.preferredWidth: 42 * Theme.fontScale
                text: Math.round(root.value * 100) + "%"
                font: Theme.typography.caption
                color: root.muted ? Theme.colors.danger : Theme.colors.textPrimary
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.motion.fastEffects.duration
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: Theme.motion.standard.duration
                easing.type: Theme.motion.standard.easing
            }
        }
    }
}
