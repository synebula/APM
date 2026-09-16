import QtQuick
import QtQuick.Window
import Quickshell
import "tests"

ShellRoot {
    ThemeTest {}

    WindowStateTest {}

    NotificationTest {}

    CommandQueueTest {}

    LauncherTest {}

    Window {
        visible: true
        width: 600
        height: 420

        ControlsTest {}
    }
}
