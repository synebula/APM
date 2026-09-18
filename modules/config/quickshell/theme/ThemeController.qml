pragma Singleton
import "../config"
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    function setPalette(paletteId: string): bool {
        const palette = PaletteCatalog.find(paletteId);
        if (!palette)
            return false;

        AppearanceSettings.update({ "paletteId": palette.paletteId });
        return true;
    }

    function setTheme(themeId: string): bool {
        const theme = ThemeCatalog.find(themeId);
        if (!theme)
            return false;

        AppearanceSettings.update({
            "themeId": theme.themeId
        });
        return true;
    }

    function resetColors() {
        AppearanceSettings.update({ "accentId": "" });
    }

    function canSetColorMode(mode: string): bool {
        if (!["system", "light", "dark"].includes(mode))
            return false;
        const targetMode = mode === "system" ? Theme.resolvedColorMode : mode;
        return PaletteCatalog.findVariant(Theme.palette.paletteId, targetMode) !== null;
    }

    function setColorMode(mode: string): bool {
        if (!root.canSetColorMode(mode))
            return false;
        AppearanceSettings.update({ "colorMode": mode });
        return true;
    }

    function toggleColorMode(): bool {
        return root.setColorMode(Theme.isDark ? "light" : "dark");
    }

    function setAccent(accentId: string): bool {
        if (!PaletteCatalog.accentIds(Theme.paletteVariant).includes(accentId))
            return false;

        AppearanceSettings.update({ "accentId": accentId });
        return true;
    }

    function nextPalette() {
        const palettes = PaletteCatalog.palettes;
        const index = palettes.findIndex(palette => {
            return palette.paletteId === Theme.palette.paletteId;
        });
        root.setPalette(palettes[(index + 1) % palettes.length].paletteId);
    }

    function nextAccent() {
        const accents = PaletteCatalog.accentIds(Theme.paletteVariant);
        root.setAccent(accents[(accents.indexOf(Theme.accentId) + 1) % accents.length]);
    }

    function setScale(key: string, value: real): bool {
        const ranges = {
            "fontScale": [0.75, 2],
            "spacingScale": [0.5, 2],
            "radiusScale": [0, 3],
            "motionScale": [0, 4]
        };
        if (!Object.keys(ranges).includes(key) || !Number.isFinite(value))
            return false;

        const range = ranges[key];
        const changes = {};
        changes[key] = Math.max(range[0], Math.min(range[1], value));
        AppearanceSettings.update(changes);
        return true;
    }

    IpcHandler {
        function setPalette(paletteId: string): bool {
            return root.setPalette(paletteId);
        }

        function setTheme(themeId: string): bool {
            return root.setTheme(themeId);
        }

        function resetColors() {
            root.resetColors();
        }

        function setAccent(accentId: string): bool {
            return root.setAccent(accentId);
        }

        function setColorMode(mode: string): bool {
            return root.setColorMode(mode);
        }

        function toggleColorMode(): bool {
            return root.toggleColorMode();
        }

        function nextPalette() {
            root.nextPalette();
        }

        function nextAccent() {
            root.nextAccent();
        }

        function setFontScale(value: real): bool {
            return root.setScale("fontScale", value);
        }

        function setRadiusScale(value: real): bool {
            return root.setScale("radiusScale", value);
        }

        function setSpacingScale(value: real): bool {
            return root.setScale("spacingScale", value);
        }

        function setMotionScale(value: real): bool {
            return root.setScale("motionScale", value);
        }

        target: "theme"
    }
}
