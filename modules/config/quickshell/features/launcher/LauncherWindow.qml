pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import Quickshell.Wayland

import "../../theme"
import "../../ui/containers"
import "../../ui/controllers"
import "../../ui/controls"
import "../../ui/effects"

ModalWindow {
    id: root
    isOpen: controller.isOpen
    onCloseRequested: controller.close()
    exclusiveZone: -1
    WlrLayershell.namespace: "quickshell-launcher"

    LauncherController {
        id: controller
        onOpened: {
            searchInput.text = "";
            searchInput.forceActiveFocus();
        }
    }

    SurfaceFrame {
        id: card
        anchors.centerIn: parent
        width: Math.min(parent.width - Theme.spacing.section * 2, 640 * Theme.controlScale)
        height: Math.min(parent.height - Theme.spacing.section * 2, content.implicitHeight + Theme.spacing.large * 2)
        fill: Theme.colors.surface
        radius: Theme.shape.panelRadius
        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: Theme.spacing.large
            spacing: Theme.spacing.medium

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacing.large
                IconGlyph {
                    text: controller.provider.glyph
                    font.pixelSize: Theme.typography.headingSize
                    color: Theme.colors.accent
                }
                T.TextField {
                    id: searchInput
                    Layout.fillWidth: true
                    implicitHeight: Theme.components.actionRow.height * 1.4
                    font.family: Theme.typography.family
                    font.pixelSize: Theme.typography.headingSize
                    color: Theme.colors.textPrimary
                    selectionColor: Theme.colors.accent
                    selectedTextColor: Theme.colors.accentForeground
                    placeholderText: controller.provider.placeholder
                    placeholderTextColor: Theme.colors.textSecondary
                    verticalAlignment: TextInput.AlignVCenter
                    selectByMouse: true
                    clip: true
                    onTextChanged: controller.query = text
                    Keys.onDownPressed: controller.selectNext(1)
                    Keys.onUpPressed: controller.selectNext(-1)
                    Keys.onTabPressed: event => {
                        if (event.modifiers & Qt.ControlModifier)
                            controller.open(controller.mode === "applications" ? "commands" : "applications");
                        else
                            controller.selectNext(1);
                    }
                    Keys.onBacktabPressed: controller.selectNext(-1)
                    Keys.onReturnPressed: event => controller.launch(!!(event.modifiers & Qt.ShiftModifier))
                    Keys.onEnterPressed: event => controller.launch(!!(event.modifiers & Qt.ShiftModifier))
                }
                IconButton {
                    glyph: controller.mode === "applications" ? "" : "󰍉"
                    tooltipText: "切换搜索模式 (Ctrl+Tab)"
                    onClicked: controller.open(controller.mode === "applications" ? "commands" : "applications")
                }
            }

            Divider {
                Layout.fillWidth: true
                visible: results.count > 0
            }

            ListView {
                id: results
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.preferredHeight: Math.min(count, 10) * (Theme.components.actionRow.height + Theme.spacing.large)
                visible: count > 0
                clip: true
                model: controller.results
                currentIndex: controller.selectedIndex
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
                boundsBehavior: Flickable.StopAtBounds
                WheelScrollController {
                    flickable: results
                }

                delegate: ActionRow {
                    id: resultRow
                    required property var modelData
                    required property int index
                    width: results.width
                    height: 50 * Theme.controlScale
                    iconSize: 26 * Theme.controlScale
                    font.pixelSize: 14 * Theme.fontScale
                    leftPadding: Theme.spacing.large
                    rightPadding: Theme.spacing.large
                    spacing: Theme.spacing.large
                    text: modelData.label
                    glyph: controller.provider.glyph
                    icon.name: modelData.icon
                    selected: index === controller.selectedIndex
                    onHoveredChanged: {
                        if (hovered)
                            controller.selectedIndex = index;
                    }
                    onClicked: {
                        controller.selectedIndex = index;
                        controller.launch(false);
                    }
                }
            }
        }
    }
}
