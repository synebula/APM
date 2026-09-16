pragma ComponentBehavior: Bound
import QtQuick
import Quickshell.Services.SystemTray
import Quickshell.Widgets

import "../../services"
import "../../theme"
import "../../ui/controls"

Row {
    id: root
    spacing: Theme.spacing.small

    property var barWindow

    Repeater {
        model: SystemTray.items.values

        delegate: BarButton {
            id: btn
            required property var modelData

            tooltipText: modelData.tooltipTitle || modelData.title || modelData.id

            onClicked: {
                if (trayMenu.visible) {
                    trayMenu.close();
                    return;
                }

                const window = WindowManagerService.findWindowForTray(modelData);
                if (window && !window.focused)
                    WindowManagerService.focusWindow(window.windowId);
                else
                    modelData.activate();
            }

            onRightClicked: {
                if (modelData.hasMenu && modelData.menu) {
                    trayMenu.toggle();
                } else {
                    modelData.secondaryActivate();
                }
            }

            content: IconImage {
                source: btn.modelData.icon
                implicitWidth: Theme.components.iconButton.iconSize
                implicitHeight: Theme.components.iconButton.iconSize
                anchors.verticalCenter: parent ? parent.verticalCenter : undefined
            }

            TrayMenu {
                id: trayMenu
                menuHandle: btn.modelData.menu
                anchorItem: btn
                barWindow: root.barWindow
            }
        }
    }
}
