.pragma library

// Runtime defaults are kept in one place. config.default.jsonc remains the
// documented, user-editable template layered on top of these safe fallbacks.
function create() {
    return {
        "workspaces": {
            "byOutput": ({}),
            "default": ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"],
            "autoDistribute": true
        },
        "bar": {
            "showWorkspaces": true,
            "showWindowTitle": true,
            "showMedia": true,
            "showClock": true,
            "showNotifications": true,
            "showTray": true,
            "showMetrics": true,
            "showIndicators": true,
            "showTaskbar": false
        },
        "wallpaper": {
            "directory": "~/doc/wallpapers",
            "defaultPath": "",
            "transitionDurationMs": 800,
            "carouselEnabled": true,
            "carouselIntervalMinutes": 60,
            "carouselRandom": true,
            "overviewEnabled": true,
            "overviewBlurRadius": 48,
            "overviewDim": 0.3,
            "overviewSaturation": 0.85,
            "overviewContrast": 0.9
        },
        "notifications": {
            "timeoutMs": 5000,
            "historyLimit": 50,
            "toastLimit": 4,
            "toastsOnFocusedScreenOnly": true
        },
        "clock": {
            "format": "yyyy/MM/dd HH:mm",
            "detailedFormat": "dddd, MMMM d yyyy (HH:mm)",
            "locale": "zh_CN"
        },
        "metrics": {
            "cpuPollIntervalMs": 5000,
            "memoryPollIntervalMs": 30000
        },
        "osd": {
            "timeoutMs": 1800
        },
        "audio": {
            "volumeStep": 0.05
        },
        "apps": {
            "taskbarExcludedAppPatterns": []
        },
        "commands": {
            "terminal": "kitty",
            "lock": "hyprlock"
        }
    };
}
