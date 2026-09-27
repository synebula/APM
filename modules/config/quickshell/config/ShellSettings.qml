pragma Singleton
import Quickshell
import "."

Singleton {
    id: root

    readonly property var workspacesByOutput: ConfigService.workspaces.byOutput
    readonly property var defaultWorkspaces: ConfigService.workspaces.default
    readonly property bool autoDistribute: ConfigService.workspaces.autoDistribute
    readonly property var taskbarExcludedAppPatterns: ConfigService.apps.taskbarExcludedAppPatterns
    readonly property int notificationTimeout: ConfigService.notifications.timeoutMs
    readonly property int notificationHistoryLimit: ConfigService.notifications.historyLimit
    readonly property int notificationToastLimit: ConfigService.notifications.toastLimit
    readonly property bool toastsOnFocusedScreenOnly: ConfigService.notifications.toastsOnFocusedScreenOnly
    readonly property string terminalCommand: ConfigService.commands.terminal
    readonly property string lockCommand: ConfigService.commands.lock

    // 状态栏各模块显隐开关
    readonly property bool barShowWorkspaces: ConfigService.bar.showWorkspaces
    readonly property bool barShowWindowTitle: ConfigService.bar.showWindowTitle
    readonly property bool barShowMedia: ConfigService.bar.showMedia
    readonly property bool barShowClock: ConfigService.bar.showClock
    readonly property bool barShowNotifications: ConfigService.bar.showNotifications
    readonly property bool barShowTray: ConfigService.bar.showTray
    readonly property bool barShowMetrics: ConfigService.bar.showMetrics
    readonly property bool barShowIndicators: ConfigService.bar.showIndicators
    readonly property bool barShowTaskbar: ConfigService.bar.showTaskbar

    // 时钟与区域格式
    readonly property string clockFormat: ConfigService.clock.format
    readonly property string clockDetailedFormat: ConfigService.clock.detailedFormat
    readonly property string clockLocale: ConfigService.clock.locale

    // 硬件监控采集频率
    readonly property int metricsCpuInterval: ConfigService.metrics.cpuPollIntervalMs
    readonly property int metricsMemoryInterval: ConfigService.metrics.memoryPollIntervalMs

    // OSD 与音频步进
    readonly property int osdTimeoutMs: ConfigService.osd.timeoutMs
    readonly property real volumeStep: ConfigService.audio.volumeStep

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
        return !root.taskbarExcludedAppPatterns.some(pattern => {
            try {
                return new RegExp(pattern, "i").test(appId);
            } catch (error) {
                return false;
            }
        });
    }
}
