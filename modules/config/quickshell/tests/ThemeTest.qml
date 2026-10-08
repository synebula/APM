import "../theme/appearance"
import "../theme/themes"
import "../theme/colors/runtime"
import "../theme/colors/presets"
import "../theme/motion/runtime"
import "../config"
import "../features/theme"
import "../services"
import "../theme"
import "../theme/colors/runtime/ColorMath.js" as ColorMath
import QtQuick
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
        ThemeController.resetMotion();
    }

    function test_motionSelectionPersistsAndStaysIndependentOfTheme() {
        const popup = createTemporaryObject(popupComponent, root, { ownerScreen: Quickshell.screens[0] });
        popup.open();
        tryCompare(popup, "transitionProgress", 1);
        const gentle = findChild(popup.contentItem, "motion-gentle");
        const follow = findChild(popup.contentItem, "followThemeMotion");
        verify(gentle !== null && follow !== null, "Motion selection rows must be instantiated");
        verify(follow.selected, "Motion selection should initially follow the theme");
        gentle.clicked();
        verify(gentle.selected, "Clicking Gentle must select its row");
        verify(!Theme.motionFollowsTheme, "Selecting a profile must override the theme's motion");
        compare(Theme.motionProfile, MotionCatalog.find("gentle"));
        tryVerify(() => root.persistedAppearance.motionId === "gentle");
        ThemeController.setMotionScale(1.5);
        ThemeController.setTheme("flat");
        compare(Theme.motionProfile.motionId, "gentle");
        compare(Theme.motion.standard.duration, 510);
        compare(Theme.palette.paletteId, "pastel-relief");
        follow.clicked();
        verify(Theme.motionFollowsTheme, "Follow action must reset the motion override");
        compare(Theme.motionProfile, Theme.definition.motion);
        compare(Theme.motion.standard.duration, 225);
        compare(Theme.motion.scale, 1.5);
        tryVerify(() => root.persistedAppearance.motionId === "");
        ThemeController.setMotionScale(1);
        popup.close();
        tryCompare(popup, "visible", false);
    }

    function test_motionCatalogAndInvalidSelection() {
        compare(MotionCatalog.profiles.length, 3);
        const seen = {};
        for (const profile of MotionCatalog.profiles) {
            verify(!seen[profile.motionId]);
            seen[profile.motionId] = true;
            verify(profile.displayName.length > 0);
            verify(profile.description.length > 0);
            verify(ThemeController.setMotion(profile.motionId));
            compare(Theme.motionProfile, profile);
            compare(Theme.motion.standard.easing, profile.standard.easing);
            compare(JSON.stringify(Theme.motion.standard.curve), JSON.stringify(profile.standard.curve));
        }
        verify(!ThemeController.setMotion("missing"));
        compare(Theme.motionProfile.motionId, "gentle");
        AppearanceSettings.update({ motionId: "missing" });
        verify(Theme.motionFollowsTheme);
        compare(Theme.motionProfile, Theme.definition.motion);
        ThemeController.resetMotion();
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
            verify(theme.geometry.shape !== null);
            verify(theme.geometry.shape.smallRadius >= 0);
            verify(theme.geometry.shape.controlRadius >= 0);
            verify(theme.geometry.shape.panelRadius >= 0);
            verify(theme.geometry.shape.roundRadius >= 0);

            verify(theme.material.border !== null);
            verify(theme.material.border.width >= 0);
            verify(theme.material.border.opacity >= 0 && theme.material.border.opacity <= 1);
            verify(["outline", "surfaceVariant", "transparent"].includes(theme.material.border.colorPolicy));

            verify(theme.material.elevation !== null);
            compare(typeof theme.material.elevation.shadowEnabled, "boolean");
            compare(typeof theme.material.elevation.highlightEnabled, "boolean");
            verify(theme.material.elevation.shadowOpacity >= 0 && theme.material.elevation.shadowOpacity <= 1);
            verify(theme.material.elevation.darkShadowOpacity >= 0 && theme.material.elevation.darkShadowOpacity <= 1);
            verify(theme.material.elevation.highlightOpacity >= 0 && theme.material.elevation.highlightOpacity <= 1);
            verify(theme.material.elevation.darkHighlightOpacity >= 0 && theme.material.elevation.darkHighlightOpacity <= 1);
            verify(["black", "foreground"].includes(theme.material.elevation.shadowColorPolicy));
            verify(["black", "foreground"].includes(theme.material.elevation.darkShadowColorPolicy));

            verify(theme.material.surface !== null);
            verify(["solid", "gradient", "acrylic", "liquid"].includes(theme.material.surface.mode));
            verify(theme.material.surface.fillOpacity >= 0 && theme.material.surface.fillOpacity <= 1);
            verify(theme.material.surface.blurRadius >= 0);

            verify(theme.geometry.spacing !== null);
            verify(theme.geometry.spacing.density > 0);
            verify(theme.geometry.spacing.tiny >= 0);
            verify(theme.geometry.spacing.small >= 0);
            verify(theme.geometry.spacing.medium >= 0);
            verify(theme.geometry.spacing.large >= 0);

            verify(theme.typography !== null);

            verify(theme.motion !== null);
            verify(theme.motion.duration >= 0);
        }
        verify(ThemeCatalog.find("flat") !== null);
        verify(ThemeCatalog.find("neumorphic") !== null);
        verify(ThemeCatalog.find("liquid-glass") !== null);
        verify(ThemeCatalog.find("frosted-glass") !== null);
        verify(ThemeCatalog.find("ios-glass") === null);
        verify(ThemeCatalog.find("ios-liquid-glass") === null);
        verify(ThemeCatalog.find("missing") === null);
    }

    function test_paletteFindVariantStrict() {
        verify(PaletteCatalog.findVariant("catppuccin", "dark") !== null);
        verify(PaletteCatalog.findVariant("catppuccin", "light") !== null);
        verify(PaletteCatalog.findVariant("catppuccin", "invalid_mode") === null);
        verify(PaletteCatalog.findVariant("non_existing_palette", "dark") === null);

        verify(PaletteCatalog.variant("catppuccin", "invalid_mode") !== null);
        verify(PaletteCatalog.variant("non_existing_palette", "dark") !== null);
    }

    function test_canSetColorModeStrict() {
        verify(ThemeController.canSetColorMode("dark"));
        verify(ThemeController.canSetColorMode("light"));
        verify(ThemeController.canSetColorMode("system"));
        verify(!ThemeController.canSetColorMode("invalid_mode"));
        verify(!ThemeController.canSetColorMode(""));

        const oldMode = AppearanceSettings.colorMode;
        verify(!ThemeController.setColorMode("invalid_mode"));
        compare(AppearanceSettings.colorMode, oldMode);
    }

    function test_semanticTokensAndColorMath() {
        verify(Theme.colors.textPrimary !== undefined);
        verify(Theme.colors.textSecondary !== undefined);
        verify(Theme.colors.accentForeground !== undefined);
        verify(Theme.colors.dangerForeground !== undefined);
        verify(Theme.colors.disabledText !== undefined);
        verify(Theme.colors.disabledSurface !== undefined);
        verify(Theme.colors.focusRing !== undefined);
        verify(Theme.colors.hoveredSurface !== undefined);
        verify(Theme.colors.selectedSurface !== undefined);

        const c1 = Qt.rgba(1, 0, 0, 1);
        const c2 = Qt.rgba(0, 0, 1, 1);
        const blended = ColorMath.blend(c1, c2, 0.5);
        verify(Math.abs(blended.r - 0.5) < 0.01);
        verify(Math.abs(blended.b - 0.5) < 0.01);
        const withAlpha = ColorMath.alpha(c1, 0.3);
        verify(Math.abs(withAlpha.a - 0.3) < 0.01);
    }

    function test_componentStateTokens() {
        // BarButton state mapping
        compare(Theme.components.barButton.background(true, false).toString(), Theme.colors.accent.toString());
        compare(Theme.components.barButton.background(false, true).toString(), Theme.colors.danger.toString());
        compare(Theme.components.barButton.background(false, false).toString(), "#00000000");
        compare(Theme.components.barButton.foreground(true, false).toString(), Theme.colors.accentForeground.toString());
        compare(Theme.components.barButton.foreground(false, true).toString(), Theme.colors.dangerForeground.toString());
        compare(Theme.components.barButton.foreground(false, false).toString(), Theme.colors.textPrimary.toString());

        // ActionButton state mapping (with primary, tonal, destructive)
        compare(Theme.components.actionButton.background(true, true).toString(), Theme.colors.accent.toString());
        compare(Theme.components.actionButton.background(true, false).toString(), "#00000000");
        compare(Theme.components.actionButton.background(true, false, true, false, false).toString(), Theme.colors.accent.toString());
        compare(Theme.components.actionButton.background(true, false, false, true, false).toString(), Theme.colors.accentContainer.toString());
        compare(Theme.components.actionButton.background(true, false, true, false, true).toString(), Theme.colors.danger.toString());
        compare(Theme.components.actionButton.background(true, false, false, true, true).toString(), Theme.colors.dangerContainer.toString());
        compare(Theme.components.actionButton.foreground(false, false, false).toString(), Theme.colors.disabledText.toString());
        compare(Theme.components.actionButton.foreground(true, true, false).toString(), Theme.colors.accentForeground.toString());
        compare(Theme.components.actionButton.foreground(true, false, true).toString(), Theme.colors.accentForeground.toString());
        compare(Theme.components.actionButton.foreground(true, false, false).toString(), Theme.colors.textPrimary.toString());
        compare(Theme.components.actionButton.foreground(true, false, false, true, false).toString(), Theme.colors.accent.toString());
        compare(Theme.components.actionButton.foreground(true, false, false, false, true).toString(), Theme.colors.danger.toString());
        compare(Theme.components.actionButton.foreground(true, false, true, false, true).toString(), Theme.colors.dangerForeground.toString());

        // ActionRow state mapping
        compare(Theme.components.actionRow.background(true, true).toString(), Theme.colors.selectedSurface.toString());
        compare(Theme.components.actionRow.background(true, true, true).toString(), Theme.colors.dangerContainer.toString());
        compare(Theme.components.actionRow.background(true, false).toString(), "#00000000");
        compare(Theme.components.actionRow.foreground(false, false, false).toString(), Theme.colors.disabledText.toString());
        compare(Theme.components.actionRow.foreground(true, false, true).toString(), Theme.colors.danger.toString());
        compare(Theme.components.actionRow.foreground(true, false, false).toString(), Theme.colors.textPrimary.toString());
        compare(Theme.components.actionRow.foreground(true, true, false).toString(), Theme.colors.accent.toString());

        // ToggleSwitch state mapping
        compare(Theme.components.toggleSwitch.trackColor(false, false).toString(), Theme.colors.disabledSurface.toString());
        compare(Theme.components.toggleSwitch.trackColor(true, true).toString(), Theme.colors.accent.toString());
        compare(Theme.components.toggleSwitch.trackColor(true, false).toString(), Theme.colors.surfaceVariant.toString());
        compare(Theme.components.toggleSwitch.knobColor(false, false).toString(), Theme.colors.disabledText.toString());
        compare(Theme.components.toggleSwitch.knobColor(true, true).toString(), Theme.colors.accentForeground.toString());
        compare(Theme.components.toggleSwitch.knobColor(true, false).toString(), Theme.colors.textSecondary.toString());

        // StatusTokens state mapping
        compare(Theme.components.status.tone(true).toString(), Theme.colors.danger.toString());
        compare(Theme.components.status.tone(false).toString(), Theme.colors.accent.toString());
        compare(Theme.components.status.foreground(true).toString(), Theme.colors.dangerForeground.toString());
        compare(Theme.components.status.foreground(false).toString(), Theme.colors.accentForeground.toString());
        compare(Theme.components.status.text(true).toString(), Theme.colors.danger.toString());
        compare(Theme.components.status.text(false).toString(), Theme.colors.textPrimary.toString());

        // CalendarTokens state mapping
        compare(Theme.components.calendar.dayBackground(true, false).toString(), Theme.colors.accent.toString());
        compare(Theme.components.calendar.dayBackground(false, true).toString(), Theme.colors.hoveredSurface.toString());
        compare(Theme.components.calendar.dayBackground(false, false).toString(), "#00000000");
        compare(Theme.components.calendar.dayForeground(true).toString(), Theme.colors.accentForeground.toString());
        compare(Theme.components.calendar.dayForeground(false).toString(), Theme.colors.textPrimary.toString());

        // ThemeCardTokens state mapping
        compare(Theme.components.themeCard.background(true).toString(), Theme.colors.selectedSurface.toString());
        compare(Theme.components.themeCard.background(false).toString(), "#00000000");
        compare(Theme.components.themeCard.borderColor(true, false).toString(), Theme.colors.accent.toString());
        compare(Theme.components.themeCard.borderColor(false, false).toString(), Theme.colors.outline.toString());
        compare(Theme.components.themeCard.accentColor(true).toString(), Theme.colors.accent.toString());
        compare(Theme.components.themeCard.accentColor(false).toString(), Theme.colors.textSecondary.toString());

        // ColorModeToggleTokens state mapping
        compare(Theme.components.colorModeToggle.trackBorder(true).toString(), Theme.colors.accent.toString());
        compare(Theme.components.colorModeToggle.trackBorder(false).toString(), Theme.colors.outline.toString());
        compare(Theme.components.colorModeToggle.knobColor(true).toString(), Theme.colors.accent.toString());
        compare(Theme.components.colorModeToggle.knobColor(false).toString(), Theme.colors.background.toString());
        compare(Theme.components.colorModeToggle.knobForeground(true).toString(), Theme.colors.accentForeground.toString());
        compare(Theme.components.colorModeToggle.knobForeground(false).toString(), Theme.colors.accent.toString());
        compare(Theme.components.colorModeToggle.iconColor(true).toString(), Theme.colors.accent.toString());
        compare(Theme.components.colorModeToggle.iconColor(false).toString(), Theme.colors.textSecondary.toString());

        // NotificationTokens state mapping
        compare(Theme.components.notification.indicatorTone(true, false).toString(), Theme.colors.danger.toString());
        compare(Theme.components.notification.indicatorTone(false, true).toString(), Theme.colors.accent.toString());
        compare(Theme.components.notification.indicatorTone(false, false).toString(), Theme.colors.textPrimary.toString());
        compare(Theme.components.notification.urgencyColor(2).toString(), Theme.colors.danger.toString());
        compare(Theme.components.notification.urgencyColor(1).toString(), Theme.colors.accent.toString());
        compare(Theme.components.notification.appNameColor(2).toString(), Theme.colors.danger.toString());
        compare(Theme.components.notification.appNameColor(1).toString(), Theme.colors.accent.toString());
        compare(Theme.components.notification.accentStripColor(true, 1).toString(), Theme.colors.accent.toString());
        compare(Theme.components.notification.accentStripColor(false, 2).toString(), Theme.colors.danger.toString());
        verify(Theme.components.notification.cardBackground(true, false, false, 1) !== undefined);
        verify(Theme.components.notification.cardBorderColor(false, true, true, 1) !== undefined);
        verify(Theme.components.notification.emptyBadgeColor(false) !== undefined);
        verify(Theme.components.notification.cardWidth > 0);
        verify(Theme.components.notification.overflowBadgeHeight > 0);

        // PopupTokens state mapping
        compare(Theme.components.popup.swatchBorderColor(true, false).toString(), Theme.colors.textPrimary.toString());
        compare(Theme.components.popup.swatchBorderColor(false, false).toString(), Theme.colors.outline.toString());
        compare(Theme.components.popup.swatchBorderWidth(true, false), 2);
        compare(Theme.components.popup.swatchBorderWidth(false, false), 1);
        verify(Theme.components.popup.tooltipMaxWidth > 0);

        // Global and component token extensions
        compare(Theme.disabledOpacity, 0.45);
        compare(Theme.shape.focusBorderWidth, 2);
        compare(Theme.components.slider.handleBorderWidth(true), 3);
        compare(Theme.components.slider.handleBorderWidth(false), 2);
        compare(Theme.components.actionButton.borderWidth(true, false, false), Theme.shape.borderWidth);
        compare(Theme.components.actionButton.borderWidth(false, false, true), Theme.surface.borderWidth);
        compare(Theme.components.actionRow.borderWidth(true, false), Theme.shape.borderWidth);
        compare(Theme.components.themeCard.borderWidth(true, false), 2);
        compare(Theme.components.themeCard.borderWidth(false, false), 1);
        compare(Theme.components.calendar.dayOpacity(true), 1.0);
        compare(Theme.components.calendar.dayOpacity(false), 0.35);
        compare(Theme.components.colorModeToggle.inactiveIconOpacity, 0.65);
        compare(Theme.components.notification.centerStatusTone(true, false).toString(), Theme.colors.warning.toString());
        compare(Theme.components.notification.centerStatusTone(false, true).toString(), Theme.colors.accent.toString());
        compare(Theme.components.bluetooth.actionColor(true).toString(), Theme.colors.danger.toString());
        compare(Theme.components.bluetooth.actionColor(false).toString(), Theme.colors.textSecondary.toString());
        verify(Theme.components.menu.separatorHeight > 0);

        // SurfaceTokens
        verify(Theme.surface.shadowMargin !== undefined);
    }

    function test_colorModeResolverState() {
        verify(["portal", "gsettings", "darkman", "fallback"].includes(ColorModeResolver.source));
        verify(["light", "dark"].includes(ColorModeResolver.systemMode));
    }

    function test_schemaVersion() {
        compare(AppearanceSettings.version, 1);
    }

    function test_stateContrast_data() {
        const rows = [];
        for (const palette of PaletteCatalog.palettes) {
            for (const variant of palette.variants) {
                rows.push({
                    "tag": palette.paletteId + "/" + variant.variantId,
                    "variant": variant
                });
            }
        }
        return rows;
    }

    function test_stateContrast(data) {
        const v = data.variant;
        const textOnBg = ColorMath.contrast(v.textPrimary, v.background);
        verify(textOnBg >= 4.5, data.tag + " textPrimary on background: " + textOnBg);

        const textOnSurface = ColorMath.contrast(v.textPrimary, v.surface);
        verify(textOnSurface >= 4.5, data.tag + " textPrimary on surface: " + textOnSurface);

        const secOnSurface = ColorMath.contrast(v.textSecondary, v.surface);
        verify(secOnSurface >= 3.0, data.tag + " textSecondary on surface: " + secOnSurface);

        const dangerFg = ColorMath.foreground(v.danger.r, v.danger.g, v.danger.b);
        const dangerContrast = ColorMath.contrast(v.danger, dangerFg);
        verify(dangerContrast >= 4.5, data.tag + " danger contrast: " + dangerContrast);
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
        compare(Theme.typography.body.pixelSize, 18);
        verify(Theme.components.bar.height >= 45);
        ThemeController.setScale("radiusScale", 1);
        ThemeController.setScale("fontScale", 1);
    }

    function test_motionScaleUpdatesDuration() {
        verify(ThemeController.setMotionScale(1.5));
        compare(AppearanceSettings.motionScale, 1.5);
        compare(Theme.motion.scale, 1.5);
        const expectedDuration = Math.round(Theme.definition.motion.duration * 1.5 * 1.5);
        compare(Theme.motion.slowEffects.duration, expectedDuration);
        ThemeController.setMotionScale(1);
        compare(AppearanceSettings.motionScale, 1);
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
        compare(Theme.surface.borderWidth, 1);
        compare(Theme.surface.mode, "solid");
        verify(!Theme.surface.shadowEnabled);
        verify(!Theme.surface.highlightEnabled);
        verify(!Theme.surface.isGlass);
        verify(!Theme.surface.isGradient);
        verify(!Theme.surface.layerEffectsEnabled);
        verify(ThemeController.setTheme("neumorphic"));
        compare(Theme.definition.themeId, "neumorphic");
        compare(Theme.surface.borderWidth, 0);
        compare(Theme.surface.mode, "gradient");
        verify(Theme.surface.shadowEnabled);
        verify(Theme.surface.highlightEnabled);
        verify(!Theme.surface.isGlass);
        verify(Theme.surface.isGradient);
        verify(Theme.surface.layerEffectsEnabled);
        verify(ThemeController.setTheme("frosted-glass"));
        compare(Theme.definition.themeId, "frosted-glass");
        compare(Theme.surface.borderWidth, 1);
        compare(Theme.surface.mode, "acrylic");
        compare(Theme.surface.fillOpacity, 0.42);
        verify(Theme.surface.shadowEnabled);
        verify(Theme.surface.highlightEnabled);
        verify(Theme.surface.isGlass);
        verify(!Theme.surface.isLiquid);
        verify(!Theme.surface.isGradient);
        verify(!Theme.surface.layerEffectsEnabled);

        verify(ThemeController.setTheme("liquid-glass"));
        compare(Theme.definition.themeId, "liquid-glass");
        compare(Theme.surface.borderWidth, 1);
        compare(Theme.surface.mode, "liquid");
        compare(Theme.surface.fillOpacity, 0.10);
        verify(Theme.surface.shadowEnabled);
        verify(Theme.surface.highlightEnabled);
        verify(Theme.surface.isGlass);
        verify(Theme.surface.isLiquid);
        verify(!Theme.surface.isGradient);
        verify(!Theme.surface.layerEffectsEnabled);
        verify(!ThemeController.setTheme("ios-glass"));
        verify(!ThemeController.setTheme("invalid-theme"));
        ThemeController.setTheme("neumorphic");
    }

    function test_neumorphicShadowColorInDarkAndLightMode() {
        verify(ThemeController.setTheme("neumorphic"));
        verify(ThemeController.setColorMode("dark"));
        compare(Theme.surface.shadowColor.r, 0);
        compare(Theme.surface.shadowColor.g, 0);
        compare(Theme.surface.shadowColor.b, 0);
        verify(ThemeController.setColorMode("light"));
        compare(Theme.surface.shadowColor.r, Theme.colors.textPrimary.r);
        compare(Theme.surface.shadowColor.g, Theme.colors.textPrimary.g);
        compare(Theme.surface.shadowColor.b, Theme.colors.textPrimary.b);
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

    function test_themePaletteIsUsedWithoutExplicitSelection() {
        ThemeController.resetPalette();
        verify(ThemeController.setTheme("flat"));
        compare(Theme.palette.paletteId, "catppuccin");
        compare(Theme.palette, Theme.definition.palette);
        verify(ThemeController.setTheme("neumorphic"));
        compare(Theme.palette.paletteId, "pastel-relief");
        verify(ThemeController.setPalette("nord"));
        verify(ThemeController.setTheme("flat"));
        compare(Theme.palette.paletteId, "nord");
    }

    function test_followThemePaletteControlResetsAndPersistsSelection() {
        verify(ThemeController.setPalette("nord"));
        verify(ThemeController.setColorMode("dark"));
        verify(ThemeController.setAccent("green"));
        verify(!Theme.paletteFollowsTheme);
        const popup = createTemporaryObject(popupComponent, root);
        verify(popup !== null);
        const follow = findChild(popup, "followThemePalette");
        verify(follow !== null);
        verify(!follow.selected);
        follow.clicked();
        verify(Theme.paletteFollowsTheme);
        verify(follow.selected);
        compare(Theme.palette, Theme.definition.palette);
        compare(AppearanceSettings.colorMode, "dark");
        compare(AppearanceSettings.accentId, "green");
        tryVerify(() => root.persistedAppearance.paletteId === "");
        verify(ThemeController.setTheme("flat"));
        compare(Theme.palette.paletteId, "catppuccin");
        verify(ThemeController.setPalette("catppuccin"));
        verify(!Theme.paletteFollowsTheme, "Explicitly choosing the same palette still disables following");
        verify(ThemeController.setTheme("neumorphic"));
        compare(Theme.palette.paletteId, "catppuccin");
    }

    Component {
        id: previewComponent
        ThemeCard {
            width: 160
            definition: FrostedGlassTheme {
                geometry.shape.controlRadius: 19
                material {
                    border { width: 3; opacity: 0.25; colorPolicy: "surfaceVariant" }
                    elevation { shadowColorPolicy: "foreground"; shadowOpacity: 0.3 }
                }
            }
        }
    }

    function test_previewUsesCandidateTokensAndRespondsToModeAndOverrides() {
        verify(ThemeController.setTheme("flat"));
        const preview = createTemporaryObject(previewComponent, root);
        verify(preview !== null);
        const surface = findChild(preview, "themePreviewSurface");
        verify(surface !== null);
        compare(surface.fill.toString(), preview.previewVariant.surface.toString());
        verify(surface.layer.enabled, "Glass previews need their local shadow on the preview backdrop");
        compare(surface.radius, 19 * Theme.shape.scale);
        compare(surface.border.width, 3);
        compare(surface.border.color.a, Qt.rgba(0, 0, 0, 0.25).a);
        compare(surface.border.color.r, preview.previewVariant.surfaceVariant.r);
        compare(surface.surface.shadowColor.r, preview.previewVariant.textPrimary.r);
        compare(surface.color.a, Qt.rgba(0, 0, 0, 0.42).a);
        verify(!surface.isDark);
        preview.definition.material.surface.fillOpacity = 0.6;
        tryVerify(() => surface.color.a === Qt.rgba(0, 0, 0, 0.6).a);
        verify(ThemeController.setColorMode("dark"));
        verify(surface.isDark);
        compare(preview.previewVariant.variantId, "dark");
        compare(surface.fill.toString(), preview.previewVariant.surface.toString());
        compare(surface.surface.shadowColor.r, 0);
        preview.definition.material.elevation.highlightEnabled = false;
        verify(!surface.highlightEnabled);
        preview.definition.material.elevation.shadowEnabled = false;
        verify(!surface.shadowEnabled);
        verify(!surface.layer.enabled, "Disabling the candidate shadow must disable the preview effect");
        verify(ThemeController.setTheme("liquid-glass"));
        compare(surface.radius, 19 * Theme.shape.scale);
        verify(!surface.isLiquid, "Candidate material must not inherit the active material");
    }

    Component {
        id: localPaletteComponent
        Catppuccin { paletteId: "local-palette" }
    }

    function test_themeCanUsePaletteOutsideCatalog() {
        const definition = ThemeCatalog.find("flat");
        const original = definition.palette;
        const local = createTemporaryObject(localPaletteComponent, root);
        verify(local !== null);
        try {
            definition.palette = local;
            ThemeController.resetPalette();
            verify(ThemeController.setTheme("flat"));
            compare(Theme.palette, local);
            verify(ThemeController.setColorMode("dark"));
            compare(Theme.paletteVariant, local.variant("dark"));
            compare(Theme.colors.background.toString(), local.variant("dark").background.toString());
        } finally {
            definition.palette = original;
        }
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
        compare(Theme.isDark, true);
        compare(Theme.paletteVariant.variantId, "dark");
        verify(ThemeController.setColorMode("light"));
        compare(Theme.paletteVariant.variantId, "light");
        compare(Theme.isDark, false);
        verify(ThemeController.setColorMode("system"));
        compare(Theme.colorMode, "system");
        verify(["dark", "light"].includes(Theme.resolvedColorMode));
        compare(Theme.isDark, Theme.resolvedColorMode === "dark");
    }

    Component {
        id: popupComponent
        ThemePopup {}
    }

    function test_themePopup() {
        const popup = popupComponent.createObject(root) as ThemePopup;
        verify(popup !== null, "ThemePopup should instantiate: " + popupComponent.errorString());
        popup.open();
        verify(popup.isOpen, "ThemePopup should open");
        popup.close();
        verify(!popup.isOpen, "ThemePopup should close");
        popup.destroy();
    }

    function test_themeSyncService() {
        verify(ThemeSyncService !== null);
        verify(ThemeSyncService.enabled);
        verify(ThemeSyncService.testMode);
        verify(ThemeSyncService.scriptPath.endsWith("sync-desktop-theme.sh"));
        verify(!ThemeSyncService.syncNow());
        verify(!ThemeSyncService.syncing);
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
