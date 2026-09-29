import "../config"
import "../config/ConfigDefaults.js" as ConfigDefaults
import "../config/ConfigSchema.js" as ConfigSchema
import "../config/PathUtil.js" as PathUtil
import "../services"
import QtQuick

TestSuite {
    id: root

    name: "Config"

    function test_failedReloadPreservesSnapshot_data() {
        return [
            { tag: "syntax", text: '{"bar":', error: "" },
            { tag: "array-root", text: "[]", error: "" },
            { tag: "null-root", text: "null", error: "" },
            { tag: "read-error", text: "", error: "Permission denied" }
        ];
    }

    function test_failedReloadPreservesSnapshot(data) {
        tryVerify(() => ConfigService.ready);
        const saved = ConfigService.currentConfig;
        try {
            verify(ConfigService.applySources([
                { name: "config.json", text: '{"bar":{"showClock":false}}' }
            ]));
            const previous = ConfigService.currentConfig;
            verify(!ConfigService.applySources([
                { name: "config.json", text: '{"bar":{"showClock":true}}' },
                { name: "config.jsonc", text: data.text, error: data.error }
            ]));
            compare(ConfigService.currentConfig, previous);
            compare(ConfigService.bar.showClock, false);
            verify(ConfigService.lastError.startsWith("config.jsonc:"));
            verify(ConfigService.applySources([
                { name: "config.json", text: '{"bar":{"showClock":false}}' },
                { name: "config.jsonc", text: '{"bar":{"showClock":true}}' }
            ]));
            compare(ConfigService.bar.showClock, true);
            compare(ConfigService.lastError, "");
        } finally {
            ConfigService.currentConfig = saved;
            ConfigService.lastError = "";
        }
    }

    function test_emptyConfigRestoresDefaults() {
        const saved = ConfigService.currentConfig;
        try {
            verify(ConfigService.applySources([
                { name: "config.jsonc", text: '{"bar":{"showClock":false}}' }
            ]));
            verify(ConfigService.applySources([{ name: "config.jsonc", text: "" }]));
            compare(ConfigService.bar.showClock, ConfigDefaults.create().bar.showClock);
        } finally {
            ConfigService.currentConfig = saved;
        }
    }

    function test_pathUtilExpandHome() {
        compare(PathUtil.expandHome("~/pictures", "/home/alex"), "/home/alex/pictures");
        compare(PathUtil.expandHome("$HOME/pictures", "/home/alex"), "/home/alex/pictures");
        compare(PathUtil.expandHome("/usr/share/backgrounds", "/home/alex"), "/usr/share/backgrounds");
        compare(PathUtil.expandHome("~", "/home/alex"), "/home/alex");
        compare(PathUtil.expandHome("", "/home/alex"), "");
        verify(!PathUtil.isValidPath("/tmp/wallpapers\ninvalid"));
        verify(!PathUtil.isValidPath("/tmp/wallpapers\rinvalid"));
        verify(!PathUtil.isValidPath("/tmp/wallpapers\u0000invalid"));
    }

    function test_configServiceDefaultsAndResolve() {
        verify(ConfigService.homeDir.length > 0, "homeDir should not be empty");
        const resolved = ConfigService.resolvePath("~/test");
        compare(resolved, ConfigService.homeDir + "/test");
        verify(Array.isArray(ConfigService.workspaces.default), "default workspaces should be array");
        verify(ConfigService.wallpaper.transitionDurationMs > 0, "transitionDurationMs should be positive");
        verify(ConfigService.wallpaper.carouselIntervalMinutes > 0, "carouselIntervalMinutes should be positive");
        verify(typeof ConfigService.wallpaper.carouselEnabled === "boolean", "carouselEnabled should be boolean");
        verify(typeof ConfigService.wallpaper.overviewEnabled === "boolean", "overviewEnabled should be boolean");
        verify(ConfigService.wallpaper.overviewBlurRadius > 0, "overviewBlurRadius should be positive");
        compare(WallpaperSettings.overviewBlurRadius, 48);
        compare(ShellSettings.volumeStep, 0.05);
    }

    function test_shellSettingsAdaptiveWorkspacesAndCommands() {
        const ws = ShellSettings.workspacesForOutput("test-screen");
        verify(Array.isArray(ws) && ws.length > 0, "workspacesForOutput should return array");
        verify(ShellSettings.terminalCommand.length > 0, "terminalCommand should not be empty");
        verify(ShellSettings.lockCommand.length > 0, "lockCommand should not be empty");
    }

    function test_wallpaperSettingsAndServiceDynamicPaths() {
        verify(!WallpaperSettings.wallpaperPath.startsWith("~"), "wallpaperPath should be expanded");
        verify(!WallpaperService.wallpaperDir.startsWith("~"), "wallpaperDir should be expanded");
        verify(WallpaperService.wallpaperDir.length > 0, "wallpaperDir should not be empty");
    }

    function test_wallpaperSettingsPreservesExplicitZeroDuration() {
        tryVerify(() => WallpaperSettings.ready);
        const configuredDuration = ConfigService.wallpaper.transitionDurationMs;
        WallpaperSettings.update({ transitionDurationMs: 0 });
        compare(WallpaperSettings.transitionDurationMs, 0);
        WallpaperSettings.update({ transitionDurationMs: -1 });
        compare(WallpaperSettings.transitionDurationMs, configuredDuration);
    }

    function test_barAndClockAndMetricsSettings() {
        verify(typeof ShellSettings.barShowWorkspaces === "boolean", "barShowWorkspaces should be boolean");
        verify(typeof ShellSettings.barShowTaskbar === "boolean", "barShowTaskbar should be boolean");
        verify(ShellSettings.clockFormat.length > 0, "clockFormat should not be empty");
        verify(ShellSettings.clockDetailedFormat.length > 0, "clockDetailedFormat should not be empty");
        verify(ShellSettings.clockLocale.length > 0, "clockLocale should not be empty");
        verify(ShellSettings.metricsCpuInterval > 0, "metricsCpuInterval should be positive");
        verify(ShellSettings.metricsMemoryInterval > 0, "metricsMemoryInterval should be positive");
        verify(ShellSettings.osdTimeoutMs > 0, "osdTimeoutMs should be positive");
        verify(ShellSettings.volumeStep > 0, "volumeStep should be positive");
        verify(Array.isArray(ShellSettings.taskbarExcludedAppPatterns), "taskbarExcludedAppPatterns should be array");
    }

    function test_configServiceParseJsonc() {
        const jsonc = "{\n"
            + "  // 单行注释\n"
            + "  \"url\": \"https://example.com/api//path\",\n"
            + "  /* 块级注释\n"
            + "     多行说明 */\n"
            + "  \"count\": 42,\n"
            + "  \"regexWithCommaBrace\": \".*,}\",\n"
            + "  \"stringWithCommaBracket\": \"foo, ]\",\n"
            + "  \"items\": [\"a\", \"b\", ],\n"
            + "}";
        const parsed = ConfigService.parseJsonc(jsonc);
        verify(parsed !== null, "parsed should not be null");
        compare(parsed.url, "https://example.com/api//path");
        compare(parsed.count, 42);
        compare(parsed.regexWithCommaBrace, ".*,}");
        compare(parsed.stringWithCommaBracket, "foo, ]");
        compare(parsed.items.length, 2);
        compare(parsed.items[0], "a");
    }

    function test_configSchemaNormalizesInvalidValues() {
        const defaults = ConfigDefaults.create();
        const normalized = ConfigSchema.normalize({
            "bar": {
                "showClock": "yes"
            },
            "wallpaper": {
                "transitionDurationMs": -1,
                "carouselIntervalMinutes": 0,
                "overviewDim": 2
            },
            "audio": {
                "volumeStep": 2
            },
            "apps": {
                "taskbarExcludedAppPatterns": ["[", "^kitty$"]
            }
        }, defaults);

        compare(normalized.bar.showClock, defaults.bar.showClock);
        compare(normalized.wallpaper.transitionDurationMs, defaults.wallpaper.transitionDurationMs);
        compare(normalized.wallpaper.carouselIntervalMinutes, defaults.wallpaper.carouselIntervalMinutes);
        compare(normalized.wallpaper.overviewDim, defaults.wallpaper.overviewDim);
        compare(normalized.audio.volumeStep, defaults.audio.volumeStep);
        compare(normalized.apps.taskbarExcludedAppPatterns.length, 1);
    }

    function test_configSchemaPreservesExplicitDisableAndRejectsUnsafeValues() {
        const defaults = ConfigDefaults.create();
        const normalized = ConfigSchema.normalize({
            "wallpaper": {
                "transitionDurationMs": 0,
                "directory": "/tmp/wallpapers\ninvalid"
            },
            "audio": {
                "volumeStep": 0
            },
            "commands": {
                "terminal": "kitty\u0000--bad"
            }
        }, defaults);

        compare(normalized.wallpaper.transitionDurationMs, 0);
        compare(normalized.wallpaper.directory, defaults.wallpaper.directory);
        compare(normalized.audio.volumeStep, defaults.audio.volumeStep);
        compare(normalized.commands.terminal, defaults.commands.terminal);
    }
}
