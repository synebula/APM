import "../../config"
import "../../services"
import "../../theme"
import "../../ui/IconGlyphs.js" as IconGlyphs
import "../../ui/containers"
import "../../ui/controls"
import "../../ui/effects"
import "../../shared/lib/audio/AudioPresentation.js" as AudioPresentation
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
    margins.bottom: 44 * Theme.spacingScale
    implicitWidth: 440 * Theme.controlScale
    implicitHeight: 104 * Theme.controlScale
    color: "transparent"
    visible: root.isOpen || container.opacity > 0

    Timer {
        interval: 1200
        running: true
        onTriggered: root.initialized = true
    }

    Timer {
        id: hideTimer

        interval: ShellSettings.osdTimeoutMs
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

    Item {
        id: container

        anchors.fill: parent
        opacity: root.isOpen ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: Theme.motion.fastEffects.duration
            }
        }

        MorphPill {
            id: morphPill

            anchors.centerIn: parent
            baseWidth: 260 * Theme.controlScale
            baseHeight: 52 * Theme.controlScale
            expanded: root.muted
            satelliteClickable: true
            onSatelliteClicked: {
                if (root.kind === "volume")
                    AudioService.toggleOutputMute();
            }

            satelliteContent: Component {
                Item {
                    anchors.fill: parent

                    Rectangle {
                        anchors.centerIn: parent
                        width: parent.width * 0.72
                        height: width
                        radius: width * 0.5
                        color: Theme.colors.danger

                        IconGlyph {
                            anchors.centerIn: parent
                            text: "󰝟"
                            font.pixelSize: Theme.typography.captionSize
                            color: Theme.colors.dangerForeground
                        }
                    }
                }
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacing.large
                anchors.rightMargin: Theme.spacing.large
                spacing: Theme.spacing.medium

                IconGlyph {
                    Layout.alignment: Qt.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    Layout.preferredWidth: 26 * Theme.controlScale
                    text: root.glyph
                    font.pixelSize: Theme.typography.headingSize
                    color: Theme.components.status.tone(root.muted)
                }

                ProgressBar {
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    value: root.value
                    progressColor: Theme.components.status.tone(root.muted)
                }

                TextLabel {
                    Layout.alignment: Qt.AlignVCenter
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignRight
                    Layout.preferredWidth: 38 * Theme.fontScale
                    text: Math.round(root.value * 100) + "%"
                    font: Theme.typography.caption
                    color: Theme.components.status.text(root.muted)
                }
            }
        }

        CompositorBlurRegion {
            id: blurRegion
            targetWindow: root
            effectEnabled: root.isOpen || container.opacity > 0.04

            Region {
                item: morphPill.mainBodyItem
                radius: morphPill.mainRadius
            }

            Region {
                item: morphPill.satelliteItem.visible ? morphPill.satelliteItem : null
                radius: morphPill.satelliteRadius
            }
        }

        Connections {
            function onPillProgressChanged() {
                blurRegion.publish();
            }

            target: morphPill
        }
    }
}
