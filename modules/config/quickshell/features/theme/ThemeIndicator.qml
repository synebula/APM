pragma ComponentBehavior: Bound
import QtQuick
import "../../ui/controls"
import "../../theme"
import "../../theme/appearance"

BarButton {
    id: root
    property var barWindow: null
    readonly property ThemePopup popup: themeLoader.item as ThemePopup
    objectName: "ThemeIndicator"

    tooltipText: "主题: " + Theme.displayName
        + "\n" + Theme.palette.displayName + " · " + Theme.resolvedColorMode + " · " + Theme.accentId
        + (ThemeController.canSetColorMode(Theme.isDark ? "light" : "dark")
            ? "\n点击选择主题 / 右键切换配色明暗" : "\n点击选择主题 / 右键定制配色")
    function toggleThemeMenu() {
        if (!themeLoader.active) {
            themeLoader.active = true;
            if (root.popup)
                root.popup.open();
        } else if (root.popup) {
            root.popup.toggle();
        }
    }

    onClicked: root.toggleThemeMenu()
    onRightClicked: {
        if (!ThemeController.toggleColorMode()) {
            themeLoader.active = true;
            if (root.popup) {
                root.popup.colorsExpanded = true;
                root.popup.open();
            }
        }
    }
    onWheel: wheel => {
        if (wheel.angleDelta.y > 0)
            ThemeController.nextPalette();
        else if (wheel.angleDelta.y < 0)
            ThemeController.nextAccent();
    }

    content: BarText {
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined
        text: "󰏘"
        color: Theme.colors.accent
    }

    Loader {
        id: themeLoader
        active: false
        sourceComponent: Component {
            ThemePopup {
                anchorItem: root
                barWindow: root.barWindow
            }
        }
    }

}
