pragma Singleton
import Quickshell
import "."

Singleton {
    id: root

    readonly property var workspacesByOutput: ConfigService.workspaces.byOutput || ({})
    readonly property var defaultWorkspaces: ConfigService.workspaces.default || ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    readonly property bool autoDistribute: ConfigService.workspaces.autoDistribute !== false
    readonly property var taskbarExcludedAppPatterns: ConfigService.apps.taskbarExcludedAppPatterns || []
    readonly property int notificationTimeout: ConfigService.notifications.timeoutMs || 5000
    readonly property int notificationHistoryLimit: ConfigService.notifications.historyLimit || 50
    readonly property int notificationToastLimit: ConfigService.notifications.toastLimit || 4
    readonly property bool toastsOnFocusedScreenOnly: ConfigService.notifications.toastsOnFocusedScreenOnly !== false
    readonly property string terminalCommand: ConfigService.commands.terminal || Quickshell.env("TERMINAL") || "kitty"
    readonly property string lockCommand: ConfigService.commands.lock || (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") ? "hyprlock" : "swaylock")

    // 状态栏各模块显隐开关
    readonly property bool barShowWorkspaces: ConfigService.bar.showWorkspaces !== false
    readonly property bool barShowWindowTitle: ConfigService.bar.showWindowTitle !== false
    readonly property bool barShowMedia: ConfigService.bar.showMedia !== false
    readonly property bool barShowClock: ConfigService.bar.showClock !== false
    readonly property bool barShowNotifications: ConfigService.bar.showNotifications !== false
    readonly property bool barShowTray: ConfigService.bar.showTray !== false
    readonly property bool barShowMetrics: ConfigService.bar.showMetrics !== false
    readonly property bool barShowIndicators: ConfigService.bar.showIndicators !== false
    readonly property bool barShowTaskbar: ConfigService.bar.showTaskbar === true

    // 时钟与区域格式
    readonly property string clockFormat: ConfigService.clock.format || "yyyy/MM/dd HH:mm"
    readonly property string clockDetailedFormat: ConfigService.clock.detailedFormat || "dddd, MMMM d yyyy (HH:mm)"
    readonly property string clockLocale: ConfigService.clock.locale || "zh_CN"

    // 硬件监控采集频率
    readonly property int metricsCpuInterval: ConfigService.metrics.cpuPollIntervalMs || 5000
    readonly property int metricsMemoryInterval: ConfigService.metrics.memoryPollIntervalMs || 30000

    // OSD 与音频步进
    readonly property int osdTimeoutMs: ConfigService.osd.timeoutMs || 1800
    readonly property real volumeStep: ConfigService.audio.volumeStep || 0.05

    function workspacesForOutput(name) {
        if (root.workspacesByOutput && root.workspacesByOutput[name] && root.workspacesByOutput[name].length > 0) {
            return root.workspacesByOutput[name];
        }

        const all = root.defaultWorkspaces;
        if (!root.autoDistribute || !Quickshell.screens || Quickshell.screens.length <= 1) {
            return all;
        }

        const screens = Quickshell.screens;
        let screenIndex = -1;
        for (let i = 0; i < screens.length; i++) {
            if (screens[i] && screens[i].name === name) {
                screenIndex = i;
                break;
            }
        }

        if (screenIndex === -1)
            return all;

        const count = screens.length;
        const total = all.length;
        const chunkSize = Math.max(1, Math.ceil(total / count));
        const start = screenIndex * chunkSize;
        const end = Math.min(total, start + chunkSize);
        if (start >= total)
            return all.slice(total - 1);
        return all.slice(start, end);
    }

    function showInTaskbar(appId) {
        return !root.taskbarExcludedAppPatterns.some(pattern => new RegExp(pattern, "i").test(appId));
    }
}
