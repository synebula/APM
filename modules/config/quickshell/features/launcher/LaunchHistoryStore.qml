pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property string path: Quickshell.statePath("launch-history.json")
    property bool ready: false
    property var pendingUses: []
    readonly property var applications: historyData.applications
    readonly property var commands: historyData.commands

    property bool legacyImportEnabled: true

    function entries(mode) {
        return mode === "applications" ? root.applications : root.commands;
    }

    function record(mode, key) {
        if (!key || !["applications", "commands"].includes(mode))
            return;
        if (!root.ready) {
            root.pendingUses = root.pendingUses.concat([
                {
                    mode: mode,
                    key: key
                }
            ]);
            return;
        }

        let targetKey = key;
        const currentEntries = root.entries(mode) || {};
        if (mode === "applications") {
            if (!currentEntries[targetKey]) {
                if (currentEntries[targetKey + ".desktop"]) {
                    targetKey = targetKey + ".desktop";
                } else if (targetKey.endsWith(".desktop") && currentEntries[targetKey.slice(0, -8)]) {
                    targetKey = targetKey.slice(0, -8);
                }
            }
        }

        const entries = Object.assign({}, currentEntries);
        const previous = entries[targetKey];
        entries[targetKey] = {
            count: (previous ? (typeof previous === "number" ? previous : (previous.count || 0)) : 0) + 1,
            lastUsed: Date.now()
        };
        historyData[mode] = entries;
        saveTimer.restart();
    }

    function finishLoading() {
        root.ready = true;

        if (root.legacyImportEnabled && (!historyData.applications || Object.keys(historyData.applications).length === 0)) {
            importLegacyProc.running = true;
        }

        const pending = root.pendingUses;
        root.pendingUses = [];
        for (const usage of pending)
            root.record(usage.mode, usage.key);
    }

    Process {
        id: importLegacyProc
        command: [
            "python3", "-c",
            "import os, json, sys\n" +
            "target = sys.argv[1]\n" +
            "sources = [\n" +
            "    target,\n" +
            "    os.path.expanduser('~/.local/state/quickshell/launch-history.json'),\n" +
            "    os.path.expanduser('~/.cache/quickshell/launcher_history.json'),\n" +
            "]\n" +
            "res = {'applications': {}, 'commands': {}}\n" +
            "for s in sources:\n" +
            "    if os.path.exists(s):\n" +
            "        try:\n" +
            "            d = json.load(open(s))\n" +
            "            apps = d.get('applications') or d.get('drun') or {}\n" +
            "            cmds = d.get('commands') or d.get('run') or {}\n" +
            "            for k, v in apps.items():\n" +
            "                c = v.get('count', 0) if isinstance(v, dict) else (v if isinstance(v, int) else 0)\n" +
            "                lu = v.get('lastUsed', 0) if isinstance(v, dict) else 0\n" +
            "                if k not in res['applications'] or c > res['applications'][k].get('count', 0):\n" +
            "                    res['applications'][k] = {'count': c, 'lastUsed': lu}\n" +
            "            for k, v in cmds.items():\n" +
            "                c = v.get('count', 0) if isinstance(v, dict) else (v if isinstance(v, int) else 0)\n" +
            "                lu = v.get('lastUsed', 0) if isinstance(v, dict) else 0\n" +
            "                if k not in res['commands'] or c > res['commands'][k].get('count', 0):\n" +
            "                    res['commands'][k] = {'count': c, 'lastUsed': lu}\n" +
            "        except: pass\n" +
            "rf_drun = os.path.expanduser('~/.cache/rofi3.druncache')\n" +
            "if os.path.exists(rf_drun):\n" +
            "    for line in open(rf_drun).read().splitlines():\n" +
            "        p = line.strip().split(' ', 1)\n" +
            "        if len(p) == 2:\n" +
            "            cnt = int(p[0])\n" +
            "            name = p[1][:-8] if p[1].endswith('.desktop') else p[1]\n" +
            "            if name not in res['applications'] or cnt > res['applications'][name].get('count', 0):\n" +
            "                res['applications'][name] = {'count': cnt, 'lastUsed': 0}\n" +
            "rf_run = os.path.expanduser('~/.cache/rofi-4.runcache')\n" +
            "if os.path.exists(rf_run):\n" +
            "    for line in open(rf_run).read().splitlines():\n" +
            "        p = line.strip().split(' ', 1)\n" +
            "        if len(p) == 2:\n" +
            "            cnt = int(p[0])\n" +
            "            raw = p[1].split('\\x1f')[0].strip(\"' \") if '\\x1f' in p[1] else p[1].strip(\"' \")\n" +
            "            if raw and (raw not in res['commands'] or cnt > res['commands'][raw].get('count', 0)):\n" +
            "                res['commands'][raw] = {'count': cnt, 'lastUsed': 0}\n" +
            "print(json.dumps(res))",
            root.path
        ]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const parsed = JSON.parse(text);
                    if (parsed && parsed.applications && Object.keys(parsed.applications).length > 0) {
                        const mergedApps = Object.assign({}, parsed.applications, historyData.applications);
                        const mergedCmds = Object.assign({}, parsed.commands, historyData.commands);
                        historyData.applications = mergedApps;
                        historyData.commands = mergedCmds;
                        saveTimer.restart();
                    }
                } catch (e) {
                    console.warn("Failed to parse imported launcher history:", e);
                }
            }
        }
    }

    Timer {
        id: saveTimer
        interval: 120
        onTriggered: file.writeAdapter()
    }

    FileView {
        id: file
        path: root.path
        preload: true
        printErrors: false
        atomicWrites: true
        onLoaded: root.finishLoading()
        onLoadFailed: error => {
            if (error !== FileViewError.FileNotFound)
                console.warn("Cannot load launcher history:", error);
            root.finishLoading();
        }
        onSaveFailed: error => console.warn("Cannot save launcher history:", error)
        JsonAdapter {
            id: historyData
            property var applications: ({})
            property var commands: ({})
        }
    }
}
