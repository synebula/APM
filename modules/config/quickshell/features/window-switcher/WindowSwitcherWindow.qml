pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Quickshell.Wayland

import "../../theme"
import "../../ui/IconGlyphs.js" as IconGlyphs
import "../../ui/containers"
import "../../ui/controls"
import "../../ui/effects"

ModalWindow {
    id: root
    isOpen: controller.isOpen
    onCloseRequested: controller.close()
    WlrLayershell.namespace: "quickshell-switcher"

    WindowSwitcherController {
        id: controller
    }

    FocusScope {
        anchors.fill: parent
        focus: root.isOpen
        Keys.onTabPressed: event => controller.cycle(event.modifiers & Qt.ShiftModifier ? -1 : 1)
        Keys.onBacktabPressed: controller.cycle(-1)
        Keys.onRightPressed: controller.cycle(1)
        Keys.onLeftPressed: controller.cycle(-1)
        Keys.onReturnPressed: controller.commit()
        Keys.onEnterPressed: controller.commit()
        Keys.onReleased: event => {
            if ([Qt.Key_Alt, Qt.Key_Meta, Qt.Key_Super_L, Qt.Key_Super_R].includes(event.key))
                controller.commit();
        }

        SurfaceFrame {
            id: panel
            anchors.centerIn: parent
            width: Math.min(parent.width - Theme.spacing.section * 2, Math.max(340 * Theme.controlScale, windows.contentWidth + Theme.spacing.extraLarge * 2))
            height: 154 * Theme.controlScale
            fill: Theme.colors.surface
            radius: Theme.shape.panelRadius
            MouseArea {
                anchors.fill: parent
            }

            ListView {
                id: windows
                anchors.fill: parent
                anchors.margins: Theme.spacing.extraLarge
                orientation: ListView.Horizontal
                spacing: Theme.spacing.medium
                clip: true
                model: controller.windows
                currentIndex: controller.selectedIndex
                highlightRangeMode: ListView.ApplyRange
                highlightMoveDuration: Theme.motion.fastEffects.duration
                boundsBehavior: Flickable.StopAtBounds
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
                delegate: ActionButton {
                    id: windowButton
                    required property var modelData
                    required property int index
                    width: 180 * Theme.controlScale
                    height: windows.height
                    fillColor: index === controller.selectedIndex ? Theme.colors.selectedSurface : "transparent"
                    onHoveredChanged: {
                        if (hovered)
                            controller.selectedIndex = index;
                    }
                    onClicked: {
                        controller.selectedIndex = index;
                        controller.commit();
                    }
                    contentItem: ColumnLayout {
                        spacing: Theme.spacing.medium
                        IconGlyph {
                            text: windowButton.modelData ? IconGlyphs.application(windowButton.modelData.appId, windowButton.modelData.title) : ""
                            font.pixelSize: Theme.typography.headingSize * 2
                            color: Theme.colors.accent
                            Layout.alignment: Qt.AlignHCenter
                        }
                        TextLabel {
                            text: windowButton.modelData ? windowButton.modelData.appId : ""
                            font.bold: true
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                        TextLabel {
                            text: windowButton.modelData ? windowButton.modelData.title : ""
                            font: Theme.typography.caption
                            color: Theme.colors.textSecondary
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }
                    }
                }
            }
        }
    }
}
