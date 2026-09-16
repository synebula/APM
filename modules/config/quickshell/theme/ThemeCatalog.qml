pragma Singleton
import "./themes"
import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property list<ThemeDefinition> themes: [
        FlatTheme {},
        NeumorphicTheme {}
    ]
    readonly property ThemeDefinition defaultTheme: root.find("neumorphic")

    function find(themeId: string): ThemeDefinition {
        return root.themes.find(theme => {
            return theme.themeId === themeId;
        }) || null;
    }
}
