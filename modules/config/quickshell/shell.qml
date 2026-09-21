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
    // 预热/常驻单例服务，确保 IPC 处理、主题桌面同步与提权代理在启动时立即就绪
    readonly property var _themeController: ThemeController
    readonly property var _themeSyncService: ThemeSyncService
    readonly property var _sessionActions: SessionActions
    readonly property var _polkitService: PolkitService

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
