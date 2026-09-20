import "../config"
import "../config/PathUtil.js" as PathUtil
import "../services"
import QtQuick

TestSuite {
    id: root

    name: "Config"

    function test_pathUtilExpandHome() {
        compare(PathUtil.expandHome("~/pictures", "/home/alex"), "/home/alex/pictures");
        compare(PathUtil.expandHome("$HOME/pictures", "/home/alex"), "/home/alex/pictures");
        compare(PathUtil.expandHome("/usr/share/backgrounds", "/home/alex"), "/usr/share/backgrounds");
        compare(PathUtil.expandHome("~", "/home/alex"), "/home/alex");
        compare(PathUtil.expandHome("", "/home/alex"), "");
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
}
