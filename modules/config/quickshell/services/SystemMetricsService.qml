pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int cpuPercent: 0
    property int memoryPercent: 0
    property real memoryUsedBytes: 0
    property real memoryTotalBytes: 0
    property int temperatureCelsius: 0
    property var cpuHistory: []
    property var memoryHistory: []
    property real _prevIdle: 0
    property real _prevTotal: 0

    function _parseStat(text) {
        const line = (text || "").split("\n")[0];
        const parts = line.trim().split(/\s+/);
        if (parts.length < 5 || parts[0] !== "cpu")
            return;

        let total = 0;
        for (let i = 1; i < Math.min(parts.length, 9); i++)
            total += Number(parts[i]) || 0;
        const idle = (Number(parts[4]) || 0) + (Number(parts[5]) || 0);
        if (root._prevTotal > 0) {
            const dTotal = total - root._prevTotal;
            const dIdle = idle - root._prevIdle;
            const usage = dTotal > 0 ? Math.max(0, Math.min(100, Math.round((1 - dIdle / dTotal) * 100))) : 0;
            root.cpuPercent = usage;
            const h = (root.cpuHistory || []).slice();
            h.push(usage);
            if (h.length > 30)
                h.shift();

            root.cpuHistory = h;
        }
        root._prevTotal = total;
        root._prevIdle = idle;
    }

    function _parseMem(text) {
        let total = 0;
        let available = 0;
        const lines = (text || "").split("\n");
        for (let i = 0; i < lines.length; i++) {
            if (lines[i].startsWith("MemTotal:"))
                total = parseInt(lines[i].replace(/[^0-9]/g, ""), 10);
            else if (lines[i].startsWith("MemAvailable:"))
                available = parseInt(lines[i].replace(/[^0-9]/g, ""), 10);
        }
        if (total <= 0)
            return;

        const used = Math.max(0, total - available);
        root.memoryTotalBytes = total * 1024;
        root.memoryUsedBytes = used * 1024;
        const pct = Math.round((used / total) * 100);
        root.memoryPercent = pct;
        const mh = (root.memoryHistory || []).slice();
        mh.push(pct);
        if (mh.length > 30)
            mh.shift();

        root.memoryHistory = mh;
    }

    function _parseTemp(text) {
        const milli = parseInt((text || "").trim(), 10);
        if (!isNaN(milli) && milli > 0)
            root.temperatureCelsius = Math.round(milli / 1000);
    }

    Process {
        id: cpuProc

        command: ["cat", "/proc/stat"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root._parseStat(text)
        }
    }

    Process {
        id: memProc

        command: ["cat", "/proc/meminfo"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root._parseMem(text)
        }
    }

    Process {
        id: tempProc

        command: ["sh", "-c", "for d in /sys/class/hwmon/hwmon*; do n=$(cat \"$d/name\" 2>/dev/null); if [ \"$n\" = k10temp ]; then cat \"$d/temp1_input\"; exit 0; fi; done; for d in /sys/class/hwmon/hwmon*; do n=$(cat \"$d/name\" 2>/dev/null); if [ \"$n\" = zenpower ] || [ \"$n\" = coretemp ]; then cat \"$d/temp1_input\"; exit 0; fi; done; cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: root._parseTemp(text)
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            cpuProc.running = true;
            tempProc.running = true;
        }
    }

    Timer {
        interval: 800
        running: true
        repeat: false
        onTriggered: cpuProc.running = true
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: memProc.running = true
    }
}
