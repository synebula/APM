import "../../theme"
import "../../ui/containers"
import "../../ui/controllers"
import "../calendar"
import "../media"
import "../metrics"
import "../notifications"
import "../tray"
import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: root

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "quickshell"
    implicitHeight: Theme.components.bar.height
    color: "transparent"
    exclusiveZone: implicitHeight

    anchors {
        top: true
        left: true
        right: true
    }

    Rectangle {
        id: barBackground

        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            topMargin: Theme.components.bar.inset
            leftMargin: Theme.components.bar.inset
            rightMargin: Theme.components.bar.inset
        }
        height: Theme.components.bar.height - Theme.components.bar.inset
        color: Theme.components.bar.background
        border.color: Theme.components.bar.borderColor
        border.width: 0

        MouseArea {
            anchors.fill: parent
            onClicked: PopupCoordinator.closeActive()
        }

        // Left modules
        Row {
            anchors.left: parent.left
            anchors.leftMargin: Theme.components.bar.padding
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.components.bar.padding

            BarGroup {
                WorkspaceSwitcher {
                    screen: root.screen
                }
            }

            BarGroup {
                ActiveWindowTitle {
                    screen: root.screen
                }
            }
        }

        // Center modules
        Row {
            anchors.centerIn: parent
            spacing: Theme.components.bar.padding

            BarGroup {
                id: mediaGroup

                MediaIndicator {
                    barWindow: root
                    anchorItem: mediaGroup
                }
            }

            BarGroup {
                id: clockGroup

                Row {
                    spacing: Theme.spacing.small

                    ClockIndicator {
                        barWindow: root
                        anchorItem: clockGroup
                    }

                    NotificationIndicator {
                        barWindow: root
                        anchorItem: clockGroup
                    }
                }
            }
        }

        // Right modules
        Row {
            anchors.right: parent.right
            anchors.rightMargin: Theme.components.bar.padding
            anchors.verticalCenter: parent.verticalCenter
            spacing: Theme.components.bar.padding

            // BarGroup {
            //     Taskbar {
            //         screen: root.screen
            //     }
            // }

            BarGroup {
                SystemTrayView {
                    barWindow: root
                }
            }

            BarGroup {
                SystemMetricsIndicator {}
            }

            BarGroup {
                SystemIndicators {
                    barWindow: root
                }
            }
        }
    }
}
