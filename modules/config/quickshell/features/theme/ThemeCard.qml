pragma ComponentBehavior: Bound
import "../../theme"
import "../../ui/controls"
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts

ActionButton {
    id: root

    required property ThemeDefinition definition
    readonly property PaletteDefinition previewPalette: PaletteCatalog.find(root.definition.defaultPaletteId) || PaletteCatalog.defaultPalette
    readonly property PaletteVariant previewVariant: PaletteCatalog.variant(root.previewPalette.paletteId, "light")
    readonly property color previewBorderColor: root.definition.border.colorPolicy === "transparent" ? "transparent" : root.previewVariant.outline

    objectName: "theme-" + root.definition.themeId
    text: root.definition.displayName
    tooltipText: root.definition.description + " · 建议搭配 " + root.previewPalette.displayName
    padding: Theme.spacing.medium

    background: Rectangle {
        color: Theme.components.themeCard.background(root.checked)
        radius: Theme.shape.controlRadius
        border.width: root.checked || root.visualFocus ? 2 : 1
        border.color: Theme.components.themeCard.borderColor(root.checked, root.visualFocus)
    }

    contentItem: ColumnLayout {
        spacing: Theme.spacing.small

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.round(62 * Theme.controlScale)
            radius: Theme.shape.smallRadius
            color: root.previewVariant.background

            Rectangle {
                id: sample
                anchors.centerIn: parent
                width: parent.width - Theme.spacing.large * 2
                height: Math.round(32 * Theme.controlScale)
                radius: Theme.shape.controlRadius
                color: root.previewVariant.surface
                opacity: root.definition.surface.fillOpacity
                border.width: root.definition.border.width
                border.color: root.previewBorderColor
                gradient: root.definition.surface.mode === "gradient" ? sampleGradient : null
                layer.enabled: root.definition.elevation.shadowStyle !== "none" || root.definition.surface.blurRadius > 0
                layer.effect: MultiEffect {
                    blurEnabled: root.definition.surface.blurRadius > 0
                    blur: root.definition.surface.blurRadius
                    shadowEnabled: true
                    shadowColor: Qt.rgba(0, 0, 0, root.definition.elevation.shadowOpacity)
                    shadowBlur: root.definition.elevation.shadowBlur
                    shadowHorizontalOffset: root.definition.elevation.shadowHorizontalOffset
                    shadowVerticalOffset: root.definition.elevation.shadowVerticalOffset
                }

                Gradient {
                    id: sampleGradient
                    GradientStop { position: 0; color: Qt.lighter(root.previewVariant.surface, root.definition.surface.gradientLighten) }
                    GradientStop { position: 1; color: Qt.darker(root.previewVariant.surface, root.definition.surface.gradientDarken) }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: Theme.spacing.small
                    Rectangle {
                        width: Math.round(16 * Theme.controlScale)
                        height: width
                        radius: width / 2
                        color: root.previewVariant.accents[root.previewVariant.defaultAccentId]
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacing.small
                        Rectangle {
                            width: Math.round(30 * Theme.controlScale)
                            height: Math.round(3 * Theme.controlScale)
                            radius: height / 2
                            color: root.previewVariant.textPrimary
                        }
                        Rectangle {
                            width: Math.round(22 * Theme.controlScale)
                            height: Math.round(3 * Theme.controlScale)
                            radius: height / 2
                            color: root.previewVariant.textSecondary
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            TextLabel {
                text: root.text
                font.bold: true
                Layout.fillWidth: true
            }
            IconGlyph {
                text: root.checked ? "󰄬" : root.definition.glyph
                color: Theme.components.themeCard.accentColor(root.checked)
            }
        }

        TextLabel {
            Layout.fillWidth: true
            text: root.previewPalette.displayName + " · " + root.previewVariant.displayName
            font: Theme.typography.caption
            color: Theme.colors.textSecondary
            elide: Text.ElideRight
        }
    }
}
