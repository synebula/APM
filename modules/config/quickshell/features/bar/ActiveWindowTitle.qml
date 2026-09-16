import "../../services"
import "../../theme"
import "../../ui/controls"
import QtQuick

BarButton {
    id: root

    required property var screen
    readonly property var window: WindowManagerService.activeWindow

    visible: root.window !== null && (!root.screen || !root.window.outputName || root.window.outputName === root.screen.name)
    tooltipText: root.window ? "[" + root.window.appId + "] " + root.window.title : ""

    content: BarText {
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined
        text: root.window ? root.window.title : ""
        width: Math.min(implicitWidth, 240 * Theme.fontScale)
        elide: Text.ElideRight
    }
}
