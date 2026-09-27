import "theme"
import "ui/containers"
import "ui/controls"
import QtQuick
import QtQuick.Window
import Quickshell
import "tests"

ShellRoot {
    ThemeTest {}

    WindowStateTest {}

    NotificationTest {}

    CommandQueueTest {}

    PopupCoordinatorTest {}

    LauncherTest {}

    ConfigTest {}

    PolkitTest {}

    MorphPillTest {}

    WallpaperTest {}

    Window {
        visible: true
        width: 760
        height: 440
        color: Theme.colors.background

        ControlsTest {}

        Column {
            x: 350
            y: 30
            spacing: 24

            TextLabel {
                text: "MorphPill 液态粘连分裂预览"
                font: Theme.typography.title
                color: Theme.colors.textPrimary
            }

            MorphPill {
                id: previewPill

                baseWidth: 260
                baseHeight: 50
                expanded: toggleBtn.checked
                onSatelliteClicked: toggleBtn.checked = false

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

                Row {
                    anchors.centerIn: parent
                    spacing: Theme.spacing.medium

                    IconGlyph {
                        anchors.verticalCenter: parent.verticalCenter
                        text: toggleBtn.checked ? "󰝟" : "󰕾"
                        color: Theme.colors.accent
                        font.pixelSize: Theme.typography.titleSize
                    }

                    TextLabel {
                        anchors.verticalCenter: parent.verticalCenter
                        text: toggleBtn.checked ? "已静音 (点击小球吸回)" : "正常播放中"
                        font: Theme.typography.body
                        color: Theme.colors.textPrimary
                    }
                }
            }

            ActionButton {
                id: toggleBtn

                checkable: true
                checked: true
                text: checked ? "收回/融合 (Collapse)" : "分裂/派生 (Expand)"
            }
        }
    }
}
