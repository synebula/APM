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
import "theme/appearance"
import "ui/containers"
import "ui/controllers"

ShellRoot {
    id: root

    // Eager services and cross-feature desktop policy belong at the entry point.
    readonly property var themeController: ThemeController
    readonly property var themeSyncService: ThemeSyncService
    readonly property var sessionActions: SessionActions
    readonly property var polkitService: PolkitService
    property string windowIdAtPopupOpen: ""

    Connections {
        target: PopupCoordinator
        function onActivePopupChanged() {
            root.windowIdAtPopupOpen = PopupCoordinator.activePopup ? WindowManagerService.activeWindowId : "";
        }
    }

    Connections {
        target: WindowManagerService
        function onActiveWindowIdChanged() {
            const current = WindowManagerService.activeWindowId;
            if (root.windowIdAtPopupOpen && current && current !== root.windowIdAtPopupOpen)
                PopupCoordinator.closeActive();
        }
        function onFocusedWorkspaceIdChanged() { PopupCoordinator.closeActive(); }
    }

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
