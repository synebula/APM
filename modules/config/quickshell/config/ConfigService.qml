pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "."
import "./PathUtil.js" as PathUtil

Singleton {
    id: root

    readonly property string homeDir: Quickshell.env("HOME") || ""
    property bool ready: false

    readonly property var defaultData: ({
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
            "carouselIntervalMinutes": 15,
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
    })

    property var currentConfig: defaultData

    readonly property var workspaces: currentConfig.workspaces || defaultData.workspaces
    readonly property var bar: currentConfig.bar || defaultData.bar
    readonly property var wallpaper: currentConfig.wallpaper || defaultData.wallpaper
    readonly property var notifications: currentConfig.notifications || defaultData.notifications
    readonly property var clock: currentConfig.clock || defaultData.clock
    readonly property var metrics: currentConfig.metrics || defaultData.metrics
    readonly property var osd: currentConfig.osd || defaultData.osd
    readonly property var audio: currentConfig.audio || defaultData.audio
    readonly property var apps: currentConfig.apps || defaultData.apps
    readonly property var commands: currentConfig.commands || defaultData.commands

    function resolvePath(path) {
        return PathUtil.expandHome(path, root.homeDir);
    }

    function mergeDeep(base, override) {
        if (!override || typeof override !== "object")
            return base;
        const result = Object.assign({}, base);
        for (const key of Object.keys(override)) {
            if (override[key] !== null && typeof override[key] === "object" && !Array.isArray(override[key])) {
                result[key] = mergeDeep(base[key] || {}, override[key]);
            } else {
                result[key] = override[key];
            }
        }
        return result;
    }

    function parseJsonc(text) {
        if (!text || typeof text !== "string")
            return null;
        // 第一步：安全移除注释，确保字符串字面量内部的 // 与 /* */ 不受影响
        const noComments = text.replace(/("(?:\\.|[^"\\])*")|(\/\*[\s\S]*?\*\/|\/\/[^\r\n]*)/g, (match, stringLiteral) => {
            return stringLiteral ? stringLiteral : "";
        });
        // 第二步：移除尾随逗号，同样保护字符串字面量内部的逗号与括号（如 "foo,}"）
        const cleanJson = noComments.replace(/("(?:\\.|[^"\\])*")|(,\s*(?=[}\]]))/g, (match, stringLiteral) => {
            return stringLiteral ? stringLiteral : "";
        });
        return JSON.parse(cleanJson);
    }

    function reloadConfig() {
        let merged = JSON.parse(JSON.stringify(root.defaultData));

        const defaultText = defaultJsoncFile.text() || "";
        if (defaultText.trim().length > 0) {
            try {
                const parsedDefault = root.parseJsonc(defaultText);
                if (parsedDefault)
                    merged = mergeDeep(merged, parsedDefault);
            } catch (e) {
                console.warn("ConfigService: Failed to parse default config:", e);
            }
        }

        const userJ = userJsonFile.text() || "";
        if (userJ.trim().length > 0) {
            try {
                const parsedUser = root.parseJsonc(userJ);
                if (parsedUser)
                    merged = mergeDeep(merged, parsedUser);
            } catch (e) {
                console.warn("ConfigService: Failed to parse config.json:", e);
            }
        }

        const userC = userJsoncFile.text() || "";
        if (userC.trim().length > 0) {
            try {
                const parsedUserC = root.parseJsonc(userC);
                if (parsedUserC)
                    merged = mergeDeep(merged, parsedUserC);
            } catch (e) {
                console.warn("ConfigService: Failed to parse config.jsonc:", e);
            }
        }

        root.currentConfig = merged;
        root.ready = true;
    }

    FileView {
        id: defaultJsoncFile
        path: Quickshell.shellPath("config.default.jsonc")
        preload: true
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.reloadConfig()
        onLoadFailed: error => root.reloadConfig()
    }

    FileView {
        id: userJsoncFile
        path: Quickshell.shellPath("config.jsonc")
        preload: true
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.reloadConfig()
        onLoadFailed: error => root.reloadConfig()
    }

    FileView {
        id: userJsonFile
        path: Quickshell.shellPath("config.json")
        preload: true
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.reloadConfig()
        onLoadFailed: error => root.reloadConfig()
    }

    Component.onCompleted: {
        root.reloadConfig();
    }
}
