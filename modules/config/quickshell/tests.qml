import "theme"
import QtQuick
import QtQuick.Window
import Quickshell
import "tests"

ShellRoot {
    IndicatorTest {}

    ThemeTest {}

    ThemeCompositionTest {}

    WindowStateTest {}

    NotificationTest {}

    CommandQueueTest {}

    PopupCoordinatorTest {}

    LauncherTest {}

    ConfigTest {}

    PolkitTest {}

    MorphPillTest {}

    WallpaperTest {}

    Window {
        visible: true
        width: 760
        height: 440
        color: Theme.colors.background

        ControlsTest {}
    }
}
