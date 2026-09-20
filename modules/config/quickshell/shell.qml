import QtQuick
import Quickshell
import "features/bar"
import "features/launcher"
import "features/notifications"
import "features/osd"
import "features/polkit"
import "features/session"
import "features/wallpaper"
import "features/window-switcher"
import "services"
import "theme"
import "ui/containers"

ShellRoot {
    readonly property var themeController: ThemeController
    readonly property var themeSyncService: ThemeSyncService
    readonly property var sessionActions: SessionActions
    readonly property var polkitService: PolkitService

    Variants {
        model: Quickshell.screens

        Scope {
            id: desktop

            required property var modelData

            DesktopWallpaper {
                screen: desktop.modelData
            }

            OverviewWallpaper {
                screen: desktop.modelData
            }

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

    PolkitDialog {}

    TooltipWindow {}
}
