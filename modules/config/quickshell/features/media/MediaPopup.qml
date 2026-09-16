import "../../services"
import "../../theme"
import "../../ui/containers"
import "../../ui/controls"
import QtQuick
import QtQuick.Layouts

PopupPanel {
    id: root

    readonly property var player: MediaService.activePlayer
    readonly property bool seekable: !!root.player && root.player.canSeek && root.player.lengthSupported && root.player.length > 0

    function duration(seconds) {
        const value = Math.max(0, Math.floor(seconds || 0));
        return Math.floor(value / 60) + ":" + String(value % 60).padStart(2, "0");
    }

    contentWidth: 340 * Theme.controlScale
    contentHeight: content.implicitHeight + Theme.components.popup.padding * 2

    Timer {
        interval: 1000
        repeat: true
        running: root.isOpen && !!root.player && root.player.isPlaying
        onTriggered: root.player.positionChanged()
    }

    ColumnLayout {
        id: content

        anchors.fill: parent
        anchors.margins: Theme.components.popup.padding
        spacing: Theme.spacing.large

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.large

            Rectangle {
                Layout.preferredWidth: 64 * Theme.controlScale
                Layout.preferredHeight: 64 * Theme.controlScale
                color: Theme.colors.surfaceVariant
                radius: Theme.shape.controlRadius
                clip: true

                Image {
                    id: artwork

                    anchors.fill: parent
                    source: root.player ? root.player.trackArtUrl : ""
                    fillMode: Image.PreserveAspectCrop
                }

                IconGlyph {
                    anchors.centerIn: parent
                    visible: artwork.status !== Image.Ready
                    text: "󰎈"
                    font.pixelSize: Theme.typography.headingSize
                    color: Theme.colors.accent
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.tiny

                TextLabel {
                    text: root.player ? root.player.trackTitle || "未播放媒体" : "未播放媒体"
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                TextLabel {
                    text: root.player ? root.player.trackArtist || "未知艺术家" : ""
                    font: Theme.typography.caption
                    color: Theme.colors.textSecondary
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                TextLabel {
                    text: root.player ? root.player.identity : ""
                    font: Theme.typography.caption
                    color: Theme.colors.accent
                    Layout.fillWidth: true
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacing.medium

            TextLabel {
                visible: root.seekable
                text: root.duration(root.player ? root.player.position : 0)
                font: Theme.typography.caption
                color: Theme.colors.textSecondary
            }

            WaveSeekSlider {
                Layout.fillWidth: true
                enabled: root.seekable
                value: root.seekable ? Math.max(0, Math.min(1, root.player.position / root.player.length)) : 0
                playing: !!root.player && root.player.isPlaying
                onMoved: {
                    if (root.seekable)
                        root.player.position = value * root.player.length;
                }
            }

            IconButton {
                glyph: "󰒮"
                tooltipText: "上一首"
                enabled: !!root.player && root.player.canGoPrevious
                onClicked: root.player.previous()
            }

            IconButton {
                glyph: root.player && root.player.isPlaying ? "󰏤" : "󰐊"
                tooltipText: root.player && root.player.isPlaying ? "暂停" : "播放"
                enabled: !!root.player && root.player.canTogglePlaying
                tonal: true
                onClicked: root.player.togglePlaying()
            }

            IconButton {
                glyph: "󰒭"
                tooltipText: "下一首"
                enabled: !!root.player && root.player.canGoNext
                onClicked: root.player.next()
            }
        }
    }
}
