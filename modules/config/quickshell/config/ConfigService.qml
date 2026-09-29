pragma ComponentBehavior: Bound
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
    property string lastError: ""

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

    // Commit all layers together; a broken edit must not reset the live shell.
    function applySources(sources) {
        let merged = ConfigDefaults.create();
        for (const source of sources) {
            try {
                if (source.error)
                    throw new Error(source.error);
                if (!source.text.trim())
                    continue;
                const parsed = root.parseJsonc(source.text);
                if (!ConfigSchema.isObject(parsed))
                    throw new Error("The configuration root must be an object");
                merged = ConfigSchema.mergeDeep(merged, parsed);
            } catch (e) {
                root.lastError = source.name + ": " + e.message;
                console.warn("ConfigService: keeping previous configuration:", root.lastError);
                root.ready = true;
                return false;
            }
        }
        root.currentConfig = ConfigSchema.normalize(merged, root.defaultData);
        root.lastError = "";
        root.ready = true;
        return true;
    }

    function reloadConfig() {
        return root.applySources([defaultJsoncFile, userJsonFile, userJsoncFile].map(file => ({
            name: file.path,
            text: file.text() || "",
            error: file.readError
        })));
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

    component ConfigFile: FileView {
        property string readError: ""
        preload: true
        printErrors: false
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            readError = "";
            root.requestReload();
        }
        onLoadFailed: error => {
            readError = error === FileViewError.FileNotFound ? "" : "Cannot read file (" + error + ")";
            root.requestReload();
        }
    }

    ConfigFile {
        id: defaultJsoncFile
        path: Quickshell.shellPath("config.default.jsonc")
    }

    ConfigFile {
        id: userJsoncFile
        path: Quickshell.shellPath("config.jsonc")
    }

    ConfigFile {
        id: userJsonFile
        path: Quickshell.shellPath("config.json")
    }

    Component.onCompleted: {
        root.reloadConfig();
    }
}
