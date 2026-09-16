pragma ComponentBehavior: Bound
import "../../theme"
import "../../theme/ColorMath.js" as ColorMath
import "../../ui/containers"
import "../../ui/controls"
import QtQuick
import QtQuick.Layouts

PopupPanel {
    id: root

    property bool colorsExpanded: false

    contentWidth: Math.round(340 * Theme.controlScale)
    contentHeight: Math.min(mainColumn.implicitHeight + Theme.components.popup.padding * 2,
        (root.screen ? root.screen.height : 1080) - Theme.components.bar.height - Theme.spacing.large * 2)
    alignRight: true

    Flickable {
        objectName: "themeSelectorViewport"
        anchors.fill: parent
        anchors.margins: Theme.components.popup.padding
        contentHeight: mainColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: mainColumn
            width: parent.width
            spacing: Theme.spacing.medium

            SectionHeader {
                width: parent.width
                title: "主题"
                subtitle: Theme.displayName + " · " + Theme.palette.displayName
                    + " · " + (Theme.resolvedColorMode === "dark" ? "深色" : "浅色")
                glyph: Theme.definition.glyph

                ColorModeToggle {
                    objectName: "colorModeToggle"
                    checked: Theme.resolvedColorMode === "dark"
                    onToggled: ThemeController.setColorMode(checked ? "dark" : "light")
                }
            }

            RowLayout {
                width: parent.width
                spacing: Theme.spacing.medium

                Repeater {
                    model: ThemeCatalog.themes
                    delegate: ThemeCard {
                        required property ThemeDefinition modelData
                        Layout.fillWidth: true
                        Layout.preferredWidth: 1
                        definition: modelData
                        checked: Theme.definition.themeId === modelData.themeId
                        onClicked: {
                            if (!checked) {
                                ThemeController.setTheme(modelData.themeId);
                                root.colorsExpanded = false;
                            }
                        }
                    }
                }
            }

            Divider { width: parent.width }

            ActionRow {
                objectName: "colorCustomizationToggle"
                width: parent.width
                text: "配色"
                description: Theme.palette.displayName + " · " + Theme.accentId
                onClicked: root.colorsExpanded = !root.colorsExpanded
                IconGlyph { text: root.colorsExpanded ? "󰅃" : "󰅀" }
            }

            Column {
                width: parent.width
                visible: root.colorsExpanded
                spacing: Theme.spacing.medium

                ActionButton {
                    objectName: "resetThemeColors"
                    width: parent.width
                    text: "重置强调色"
                    enabled: Theme.accentCustomized
                    onClicked: ThemeController.resetColors()
                }

                Column {
                    width: parent.width
                    spacing: Theme.spacing.tiny

                    Repeater {
                        model: PaletteCatalog.palettes
                        delegate: ActionRow {
                            id: paletteRow
                            required property PaletteDefinition modelData
                            readonly property PaletteVariant previewVariant: PaletteCatalog.variant(modelData.paletteId, Theme.resolvedColorMode)
                            objectName: "palette-" + modelData.paletteId
                            width: parent.width
                            text: modelData.displayName
                            selected: Theme.palette.paletteId === modelData.paletteId
                            onClicked: ThemeController.setPalette(modelData.paletteId)

                            Rectangle {
                                width: Math.round(12 * Theme.controlScale)
                                height: width
                                radius: width / 2
                                color: paletteRow.previewVariant.surface
                                border.width: 1
                                border.color: paletteRow.previewVariant.outline
                            }
                            Rectangle {
                                width: Math.round(12 * Theme.controlScale)
                                height: width
                                radius: width / 2
                                color: paletteRow.previewVariant.accents[paletteRow.previewVariant.defaultAccentId]
                            }
                        }
                    }
                }

                Divider { width: parent.width }

                RowLayout {
                    width: parent.width
                    TextLabel {
                        text: "强调色"
                        font: Theme.typography.caption
                        color: Theme.colors.textSecondary
                        Layout.fillWidth: true
                    }
                    TextLabel {
                        text: Theme.accentId
                        font: Theme.typography.caption
                        color: Theme.colors.accent
                    }
                }

                Flow {
                    width: parent.width
                    spacing: Theme.spacing.small
                    Repeater {
                        model: PaletteCatalog.accentIds(Theme.paletteVariant).map(accentId => ({
                            "accentId": accentId,
                            "color": Theme.paletteVariant.accents[accentId]
                        }))
                        delegate: ActionButton {
                            id: accentDot
                            required property var modelData
                            objectName: "accent-" + modelData.accentId
                            readonly property color accentColor: modelData.color
                            width: Math.round(26 * Theme.controlScale)
                            height: width
                            padding: 0
                            cornerRadius: width / 2
                            fillColor: accentColor
                            foreground: ColorMath.foreground(accentColor.r, accentColor.g, accentColor.b)
                            glyph: Theme.accentId === modelData.accentId ? "󰄬" : ""
                            tooltipText: modelData.accentId
                            borderWidth: Theme.accentId === modelData.accentId || visualFocus ? 2 : 1
                            borderColor: Theme.accentId === modelData.accentId || visualFocus ? Theme.colors.textPrimary : Theme.colors.outline
                            onClicked: ThemeController.setAccent(modelData.accentId)

                            contentItem: IconGlyph {
                                text: accentDot.glyph
                                color: accentDot.foreground
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }
            }
        }
    }
}
