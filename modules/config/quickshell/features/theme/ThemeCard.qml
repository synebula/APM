pragma ComponentBehavior: Bound
import "../../theme/colors"
import "../../theme/colors/runtime"
import "../../theme/geometry/runtime"
import "../../theme/materials/runtime"
import "../../theme"
import "../../ui/controls"
import "../../ui/containers"
import "../../ui/effects"
import QtQuick
import QtQuick.Layouts

InteractiveCard {
    id: root

    required property ThemeDefinition definition
    readonly property PaletteDefinition previewPalette: root.definition.palette
    readonly property PaletteVariant previewVariant: root.previewPalette.variant(Theme.resolvedColorMode) || root.previewPalette.defaultVariant
    readonly property bool previewIsDark: root.previewVariant.variantId === "dark"
    readonly property ColorTokens previewColors: ColorTokens {
        variant: root.previewVariant
        requestedAccentId: ""
        isDark: root.previewIsDark
    }
    readonly property ShapeTokens previewShape: ShapeTokens {
        spec: root.definition.geometry.shape
        radiusScale: Theme.shape.scale
    }
    readonly property SpacingTokens previewSpacing: SpacingTokens {
        spec: root.definition.geometry.spacing
        spacingScale: Theme.spacingScale
    }
    readonly property SurfaceTokens previewSurface: SurfaceTokens {
        spec: root.definition.material
        colors: root.previewColors
        isDark: root.previewIsDark
        controlScale: Theme.controlScale
    }

    objectName: "theme-" + root.definition.themeId
    text: root.definition.displayName
    tooltipText: root.definition.description + " · 建议搭配 " + root.previewPalette.displayName
    padding: Theme.spacing.medium

    background: Rectangle {
        color: Theme.components.themeCard.background(root.checked)
        radius: Theme.shape.controlRadius
        border.width: Theme.components.themeCard.borderWidth(root.checked, root.visualFocus)
        border.color: Theme.components.themeCard.borderColor(root.checked, root.visualFocus)
    }

    contentItem: ColumnLayout {
        spacing: Theme.spacing.small

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.round(62 * Theme.controlScale)
            radius: root.previewShape.smallRadius
            color: root.previewColors.background

            SurfaceFrame {
                id: sample
                objectName: "themePreviewSurface"
                anchors.centerIn: parent
                width: parent.width - root.previewSpacing.large * 2
                height: Math.round(32 * Theme.controlScale)
                surface: root.previewSurface
                fill: root.previewColors.surface
                isDark: root.previewIsDark
                radius: root.previewShape.controlRadius
                // This sample has its own backdrop, so local effects can render glass shadows.
                layer.enabled: root.previewSurface.shadowEnabled || root.previewSurface.blurRadius > 0

                Row {
                    anchors.centerIn: parent
                    spacing: root.previewSpacing.small
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
                font: Theme.typography.title
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
