import QtQuick
import Quickshell
import "app"
import "features/launcher"
import "features/notifications"
import "features/osd"
import "features/polkit"
import "features/wallpaper"
import "features/window-switcher"
import "surfaces/bar"
import "ui/containers"

ShellRoot {
    // 预热/常驻单例服务，确保 IPC 处理、主题桌面同步与提权代理在启动时立即就绪
    RuntimeBootstrap {}

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
