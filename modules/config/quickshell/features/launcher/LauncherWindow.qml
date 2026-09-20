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

    property bool mouseTrackingActive: false
    property point lastMousePos: Qt.point(-1, -1)

    function resetMouseTracking() {
        root.mouseTrackingActive = false;
        root.lastMousePos = Qt.point(-1, -1);
    }

    LauncherController {
        id: controller
        onOpened: {
            root.resetMouseTracking();
            searchInput.text = "";
            searchInput.forceActiveFocus();
        }
    }

    SurfaceFrame {
        id: card
        anchors.centerIn: parent
        width: Math.min(parent.width - Theme.spacing.section * 2, 640 * Theme.controlScale)
        height: Math.min(parent.height - Theme.spacing.section * 2, content.implicitHeight + Theme.spacing.large * 2)
        fill: Theme.components.surface.fill
        radius: Theme.shape.panelRadius

        CompositorBlurRegion {
            targetWindow: root
            backgroundItem: card
            radius: card.radius
        }

        MouseArea {
            anchors.fill: parent
        }
    }

    Item {
        anchors.fill: card

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
                    onTextChanged: {
                        root.resetMouseTracking();
                        controller.query = text;
                    }
                    Keys.onDownPressed: {
                        root.resetMouseTracking();
                        controller.selectNext(1);
                    }
                    Keys.onUpPressed: {
                        root.resetMouseTracking();
                        controller.selectNext(-1);
                    }
                    Keys.onTabPressed: event => {
                        root.resetMouseTracking();
                        if (event.modifiers & Qt.ControlModifier)
                            controller.open(controller.mode === "applications" ? "commands" : "applications");
                        else
                            controller.selectNext(1);
                    }
                    Keys.onBacktabPressed: {
                        root.resetMouseTracking();
                        controller.selectNext(-1);
                    }
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

                HoverHandler {
                    id: mouseTracker
                    onPointChanged: {
                        const px = point.position.x;
                        const py = point.position.y;
                        if (!root.mouseTrackingActive) {
                            root.lastMousePos = Qt.point(px, py);
                            root.mouseTrackingActive = true;
                            return;
                        }
                        const dx = px - root.lastMousePos.x;
                        const dy = py - root.lastMousePos.y;
                        if (dx * dx + dy * dy > 9) {
                            root.lastMousePos = Qt.point(px, py);
                            const idx = results.indexAt(px, py + results.contentY);
                            if (idx >= 0 && idx < results.count) {
                                controller.selectedIndex = idx;
                            }
                        }
                    }
                }

                delegate: ActionRow {
                    id: resultRow
                    required property var modelData
                    required property int index
                    width: results.width
                    height: 50 * Theme.controlScale
                    iconSize: 26 * Theme.controlScale
                    font.pixelSize: Theme.typography.titleSize
                    leftPadding: Theme.spacing.large
                    rightPadding: Theme.spacing.large
                    spacing: Theme.spacing.large
                    text: modelData.label
                    glyph: controller.provider.glyph
                    icon.name: modelData.icon
                    selected: index === controller.selectedIndex
                    hoverEnabled: false
                    onClicked: {
                        controller.selectedIndex = index;
                        controller.launch(false);
                    }
                }
            }
        }
    }
}
