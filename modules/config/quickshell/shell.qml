import QtQuick
import Quickshell
import "features/bar"
import "features/launcher"
import "features/notifications"
import "features/osd"
import "features/session"
import "features/window-switcher"
import "theme"
import "ui/containers"

ShellRoot {
    readonly property var themeController: ThemeController
    readonly property var sessionActions: SessionActions

    Variants {
        model: Quickshell.screens

        Scope {
            id: desktop

            required property var modelData

            StatusBar {
                screen: desktop.modelData
            }

            PopupBackdrop {
                screen: desktop.modelData
            }

            NotificationToastWindow {
                screen: desktop.modelData
            }
        }
    }

    LauncherWindow {}

    OsdWindow {}

    WindowSwitcherWindow {}

    ConfirmationDialog {}

    TooltipWindow {}
}
