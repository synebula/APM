pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "./ConfigDefaults.js" as ConfigDefaults
import "./ConfigSchema.js" as ConfigSchema
import "./PathUtil.js" as PathUtil

Singleton {
    id: root

    readonly property string homeDir: Quickshell.env("HOME") || ""
    property bool ready: false

    readonly property var defaultData: ConfigDefaults.create()

    property var currentConfig: ConfigSchema.normalize({}, root.defaultData)

    readonly property var workspaces: currentConfig.workspaces
    readonly property var bar: currentConfig.bar
    readonly property var wallpaper: currentConfig.wallpaper
    readonly property var notifications: currentConfig.notifications
    readonly property var clock: currentConfig.clock
    readonly property var metrics: currentConfig.metrics
    readonly property var osd: currentConfig.osd
    readonly property var audio: currentConfig.audio
    readonly property var apps: currentConfig.apps
    readonly property var commands: currentConfig.commands

    function resolvePath(path) {
        if (!PathUtil.isValidPath(path))
            return "";
        return PathUtil.expandHome(path, root.homeDir);
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
        let merged = ConfigDefaults.create();

        const defaultText = defaultJsoncFile.text() || "";
        if (defaultText.trim().length > 0) {
            try {
                const parsedDefault = root.parseJsonc(defaultText);
                if (parsedDefault)
                    merged = ConfigSchema.mergeDeep(merged, parsedDefault);
            } catch (e) {
                console.warn("ConfigService: Failed to parse default config:", e);
            }
        }

        const userJ = userJsonFile.text() || "";
        if (userJ.trim().length > 0) {
            try {
                const parsedUser = root.parseJsonc(userJ);
                if (parsedUser)
                    merged = ConfigSchema.mergeDeep(merged, parsedUser);
            } catch (e) {
                console.warn("ConfigService: Failed to parse config.json:", e);
            }
        }

        const userC = userJsoncFile.text() || "";
        if (userC.trim().length > 0) {
            try {
                const parsedUserC = root.parseJsonc(userC);
                if (parsedUserC)
                    merged = ConfigSchema.mergeDeep(merged, parsedUserC);
            } catch (e) {
                console.warn("ConfigService: Failed to parse config.jsonc:", e);
            }
        }

        root.currentConfig = ConfigSchema.normalize(merged, root.defaultData);
        root.ready = true;
    }

    Timer {
        id: reloadDebounce
        interval: 20
        repeat: false
        onTriggered: root.reloadConfig()
    }

    function requestReload() {
        reloadDebounce.restart();
    }

    FileView {
        id: defaultJsoncFile
        path: Quickshell.shellPath("config.default.jsonc")
        preload: true
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.requestReload()
        onLoadFailed: error => root.requestReload()
    }

    FileView {
        id: userJsoncFile
        path: Quickshell.shellPath("config.jsonc")
        preload: true
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.requestReload()
        onLoadFailed: error => root.requestReload()
    }

    FileView {
        id: userJsonFile
        path: Quickshell.shellPath("config.json")
        preload: true
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.requestReload()
        onLoadFailed: error => root.requestReload()
    }

    Component.onCompleted: {
        root.reloadConfig();
    }
}
