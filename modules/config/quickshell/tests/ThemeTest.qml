import "../config"
import "../features/theme"
import "../theme"
import "../theme/ColorMath.js" as ColorMath
import QtQuick
import QtTest
import Quickshell
import Quickshell.Io

TestSuite {
    id: root

    property var persistedAppearance: ({})

    function init() {
        tryVerify(() => AppearanceSettings.ready);
        ThemeController.setTheme("neumorphic");
        ThemeController.setPalette("pastel-relief");
        ThemeController.setColorMode("light");
        ThemeController.resetColors();
    }

    function test_completePalettes() {
        const seen = {};
        verify(PaletteCatalog.palettes.length > 0);
        for (const palette of PaletteCatalog.palettes) {
            verify(!seen[palette.paletteId], "Duplicate palette: " + palette.paletteId);
            seen[palette.paletteId] = true;
            verify(palette.displayName.length > 0);
            verify(palette.variant("light") !== null, palette.paletteId + " light variant");
            verify(palette.variant("dark") !== null, palette.paletteId + " dark variant");
            for (const variant of palette.variants) {
                verify(["dark", "light"].includes(variant.variantId));
                verify(PaletteCatalog.accentIds(variant).includes(variant.defaultAccentId));
                verify(ColorMath.contrast(variant.textPrimary, variant.surface) >= 4.5,
                    palette.paletteId + "/" + variant.variantId + " body contrast");
            }
        }
        verify(PaletteCatalog.find("catppuccin") !== null);
        verify(PaletteCatalog.find("missing") === null);
    }

    function test_completeThemes() {
        const seen = {};
        verify(ThemeCatalog.themes.length > 0);
        for (const theme of ThemeCatalog.themes) {
            verify(!seen[theme.themeId], "Duplicate theme: " + theme.themeId);
            seen[theme.themeId] = true;
            verify(theme.displayName.length > 0);
            verify(theme.recommendedPaletteIds.length > 0);
            for (const paletteId of theme.recommendedPaletteIds)
                verify(PaletteCatalog.find(paletteId) !== null, theme.themeId + " recommendation");
            verify(theme.shape !== null);
            verify(theme.border !== null);
            verify(theme.elevation !== null);
            verify(theme.surface !== null);
            verify(theme.spacing !== null);
            verify(theme.typography !== null);
            verify(theme.motion !== null);
        }
        verify(ThemeCatalog.find("flat") !== null);
        verify(ThemeCatalog.find("neumorphic") !== null);
        verify(ThemeCatalog.find("missing") === null);
    }

    function test_accentContrast_data() {
        const rows = [];
        for (const palette of PaletteCatalog.palettes) {
            for (const variant of palette.variants) {
                for (const accent of PaletteCatalog.accentIds(variant))
                    rows.push({
                            "tag": palette.paletteId + "/" + variant.variantId + "/" + accent,
                        "paletteId": palette.paletteId,
                        "colorMode": variant.variantId,
                        "accentId": accent
                    });
            }
        }
        return rows;
    }

    function test_accentContrast(data) {
        verify(ThemeController.setPalette(data.paletteId), data.tag + " palette selection");
        verify(ThemeController.setColorMode(data.colorMode), data.tag + " mode selection");
        verify(ThemeController.setAccent(data.accentId), data.tag + " accent selection");
        const contrast = ColorMath.contrast(Theme.colors.accent, Theme.colors.accentForeground);
        verify(contrast >= 4.5, data.tag + " contrast " + contrast);
    }

    function test_zeroRadiusAndScaledFont() {
        verify(ThemeController.setScale("radiusScale", 0));
        compare(Theme.shape.controlRadius, 0);
        compare(Theme.components.barGroup.radius, 0);
        verify(ThemeController.setScale("fontScale", 1.5));
        compare(Theme.typography.bodySize, 18);
        verify(Theme.components.bar.height >= 45);
        ThemeController.setScale("radiusScale", 1);
        ThemeController.setScale("fontScale", 1);
    }

    function test_settingsRemainWritableAfterSave() {
        ThemeController.setScale("radiusScale", 0.6);
        tryVerify(() => root.persistedAppearance.radiusScale === 0.6);
        ThemeController.setScale("radiusScale", 0);
        compare(Theme.shape.controlRadius, 0);
        tryVerify(() => root.persistedAppearance.radiusScale === 0);
        ThemeController.setScale("radiusScale", 1);
    }

    function test_invalidSelectionDoesNotChangeSettings() {
        const paletteId = AppearanceSettings.paletteId;
        const colorMode = AppearanceSettings.colorMode;
        const accentId = AppearanceSettings.accentId;
        const themeId = AppearanceSettings.themeId;
        verify(!ThemeController.setPalette("missing"));
        verify(!ThemeController.setColorMode("missing"));
        verify(!ThemeController.setAccent("missing"));
        verify(!ThemeController.setTheme("missing"));
        compare(AppearanceSettings.paletteId, paletteId);
        compare(AppearanceSettings.colorMode, colorMode);
        compare(AppearanceSettings.accentId, accentId);
        compare(AppearanceSettings.themeId, themeId);
    }

    function test_themeSelectionUpdatesSurfaceTokens() {
        verify(ThemeController.setTheme("flat"));
        compare(Theme.definition.themeId, "flat");
        compare(Theme.components.surface.borderWidth, 1);
        compare(Theme.components.surface.mode, "solid");
        verify(!Theme.components.surface.shadowEnabled);
        verify(!Theme.components.surface.highlightEnabled);
        verify(ThemeController.setTheme("neumorphic"));
        compare(Theme.definition.themeId, "neumorphic");
        compare(Theme.components.surface.borderWidth, 0);
        compare(Theme.components.surface.mode, "gradient");
        verify(Theme.components.surface.shadowEnabled);
        verify(Theme.components.surface.highlightEnabled);
    }

    function test_themeSelectionPreservesAppearance() {
        verify(ThemeController.setPalette("nord"));
        verify(ThemeController.setColorMode("dark"));
        verify(ThemeController.setAccent("green"));
        verify(ThemeController.setTheme("flat"));
        compare(Theme.definition.themeId, "flat");
        compare(AppearanceSettings.paletteId, "nord");
        compare(AppearanceSettings.colorMode, "dark");
        compare(AppearanceSettings.accentId, "green");
        compare(Theme.accentId, "green");
    }

    function test_resetAccentPreservesPaletteAndMode() {
        verify(ThemeController.setPalette("catppuccin"));
        verify(ThemeController.setColorMode("dark"));
        verify(ThemeController.setAccent("lavender"));
        verify(Theme.accentCustomized);
        ThemeController.resetColors();
        compare(Theme.palette.paletteId, "catppuccin");
        compare(Theme.colorMode, "dark");
        compare(Theme.accentId, "mauve");
        verify(!Theme.accentCustomized);
    }

    function test_themeAndAppearancePersist() {
        ThemeController.setTheme("flat");
        ThemeController.setPalette("nord");
        ThemeController.setColorMode("dark");
        ThemeController.setAccent("green");
        tryVerify(() => root.persistedAppearance.themeId === "flat"
            && root.persistedAppearance.paletteId === "nord"
            && root.persistedAppearance.colorMode === "dark"
            && root.persistedAppearance.accentId === "green");
        ThemeController.resetColors();
        tryVerify(() => root.persistedAppearance.themeId === "flat"
            && root.persistedAppearance.paletteId === "nord"
            && root.persistedAppearance.colorMode === "dark"
            && root.persistedAppearance.accentId === "");
    }

    function test_colorModeIsIndependent() {
        verify(ThemeController.setPalette("catppuccin"));
        verify(ThemeController.setColorMode("dark"));
        compare(Theme.colorMode, "dark");
        compare(Theme.resolvedColorMode, "dark");
        compare(Theme.paletteVariant.variantId, "dark");
        verify(ThemeController.setColorMode("light"));
        compare(Theme.paletteVariant.variantId, "light");
        verify(ThemeController.setColorMode("system"));
        compare(Theme.colorMode, "system");
        verify(["dark", "light"].includes(Theme.resolvedColorMode));
    }

    Component {
        id: popupComponent
        ThemePopup {}
    }

    function test_themePopup() {
        const popup = popupComponent.createObject(root);
        verify(popup !== null, "ThemePopup should instantiate");
        popup.open();
        verify(popup.isOpen, "ThemePopup should open");
        popup.close();
        verify(!popup.isOpen, "ThemePopup should close");
        popup.destroy();
    }

    name: "ThemeContract"

    FileView {
        path: Quickshell.statePath("appearance.json")
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.persistedAppearance = JSON.parse(text())
    }
}
