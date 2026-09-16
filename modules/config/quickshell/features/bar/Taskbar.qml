import "../../config"
import "../../services"
import "../../theme"
import "../../ui/IconGlyphs.js" as IconGlyphs
import "../../ui/controls"
import QtQuick

Row {
    id: root

    required property var screen

    spacing: Theme.spacing.tiny

    Repeater {
        model: WindowManagerService.windowsForScreen(root.screen).filter(window => {
            return ShellSettings.showInTaskbar(window.appId);
        })

        delegate: BarButton {
            id: windowButton

            required property var modelData

            active: modelData.focused
            urgent: modelData.urgent
            tooltipText: modelData.title || modelData.appId
            onClicked: WindowManagerService.focusWindow(modelData.windowId)
            onMiddleClicked: WindowManagerService.closeWindow(modelData.windowId)
            onRightClicked: WindowManagerService.closeWindow(modelData.windowId)

            content: IconGlyph {
                anchors.verticalCenter: parent ? parent.verticalCenter : undefined
                text: IconGlyphs.application(windowButton.modelData.appId, windowButton.modelData.title)
                color: windowButton.foreground
            }
        }
    }
}
