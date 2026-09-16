pragma ComponentBehavior: Bound
import QtQuick

import "../../config"
import "../../services"
import "../../theme"
import "../../ui/IconGlyphs.js" as IconGlyphs
import "../../ui/controls"

Row {
    id: root
    required property var screen
    spacing: Theme.spacing.tiny

    Repeater {
        model: ShellSettings.workspacesForOutput(root.screen ? root.screen.name : "")
        delegate: BarButton {
            id: workspaceButton
            required property string modelData
            readonly property var workspace: WindowManagerService.activeWorkspaceForScreen(root.screen)
            active: workspace !== null && workspace.name === modelData
            tooltipText: "工作区 " + modelData
            onClicked: WindowManagerService.switchWorkspace(modelData)

            content: Row {
                spacing: Theme.spacing.small
                anchors.verticalCenter: parent ? parent.verticalCenter : undefined

                BarText {
                    text: workspaceButton.modelData
                    color: workspaceButton.foreground
                    font.bold: workspaceButton.active
                    anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                }
                Repeater {
                    model: WindowManagerService.windowsForWorkspace(workspaceButton.modelData, root.screen ? root.screen.name : "")
                    delegate: IconGlyph {
                        required property var modelData
                        text: IconGlyphs.application(modelData.appId, modelData.title)
                        font.pixelSize: Theme.typography.captionSize
                        color: workspaceButton.foreground
                        anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                    }
                }
            }
        }
    }
}
