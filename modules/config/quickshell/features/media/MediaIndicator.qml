import "../../services"
import "../../theme"
import "../../ui/controls"
import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    property var barWindow: null
    property var anchorItem: root
    readonly property var activePlayer: MediaService.activePlayer

    visible: activePlayer !== null
    implicitWidth: visible ? layout.implicitWidth : 0
    implicitHeight: Theme.components.barButton.height

    function toggleMediaMenu() {
        if (!mediaMenuLoader.active) {
            mediaMenuLoader.active = true;
            if (mediaMenuLoader.item)
                mediaMenuLoader.item.open();
        } else if (mediaMenuLoader.item) {
            mediaMenuLoader.item.toggle();
        }
    }

    Loader {
        id: mediaMenuLoader
        active: false
        sourceComponent: Component {
            MediaPopup {
                anchorItem: root.anchorItem
                barWindow: root.barWindow
            }
        }
    }

    RowLayout {
        id: layout

        anchors.verticalCenter: parent.verticalCenter
        spacing: Theme.spacing.tiny

        // Play / Pause toggle
        BarButton {
            id: playBtn

            onClicked: {
                if (root.activePlayer && root.activePlayer.canTogglePlaying)
                    root.activePlayer.togglePlaying();
            }
            tooltipText: (root.activePlayer && root.activePlayer.isPlaying) ? "暂停播放" : "继续播放"

            content: BarText {
                text: (root.activePlayer && root.activePlayer.isPlaying) ? "󰏤" : "󰐊"
                color: Theme.colors.accent
                font.pixelSize: Theme.typography.captionSize
            }
        }

        // Title and artist display (click to open menu)
        BarButton {
            id: infoBtn

            readonly property string trackText: {
                if (!root.activePlayer)
                    return "";

                const title = root.activePlayer.trackTitle || "Media";
                const artist = root.activePlayer.trackArtist || "";
                return artist.length > 0 ? (title + " - " + artist) : title;
            }

            onClicked: root.toggleMediaMenu()
            onMiddleClicked: {
                if (root.activePlayer && root.activePlayer.canGoNext) {
                    root.activePlayer.next();
                }
            }
            tooltipText: trackText + " (左键: 播放详情 // 中键: 下一首)"

            content: RowLayout {
                spacing: Theme.spacing.small
                anchors.verticalCenter: parent.verticalCenter

                BarText {
                    text: "󰎈"
                    color: Theme.colors.accent
                    font.pixelSize: Theme.typography.captionSize
                    Layout.alignment: Qt.AlignVCenter
                }

                BarText {
                    text: infoBtn.trackText
                    color: Theme.colors.textPrimary
                    font.pixelSize: Theme.typography.captionSize
                    Layout.maximumWidth: 160 * Theme.fontScale
                    Layout.alignment: Qt.AlignVCenter
                    elide: Text.ElideRight
                }
            }
        }
    }
}
