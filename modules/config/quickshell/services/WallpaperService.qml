pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../config"
import "../shared/WallpaperSource.js" as WallpaperSource

Singleton {
    id: root

    readonly property string configuredWallpaper: WallpaperSettings.wallpaperPath
    readonly property string currentWallpaper: root.configuredWallpaper || (root.wallpapers.length > 0 ? root.wallpapers[0] : "#1e1e2e")
    readonly property bool carouselEnabled: ConfigService.wallpaper.carouselEnabled
    readonly property int carouselIntervalMinutes: ConfigService.wallpaper.carouselIntervalMinutes
    readonly property bool carouselRandom: ConfigService.wallpaper.carouselRandom
    property var wallpapers: []
    property bool isScanning: false
    property bool scanError: false
    property bool rescanRequested: false
    property int scanGeneration: 0
    property int activeScanGeneration: 0
    property string activeScanDirectory: ""
    property string wallpaperDir: {
        const configDir = ConfigService.resolvePath(ConfigService.wallpaper.directory);
        if (configDir && configDir.length > 0)
            return configDir;

        const current = root.configuredWallpaper;
        if (current && current.indexOf("/") !== -1 && !WallpaperSource.isSolid(current)) {
            return current.substring(0, current.lastIndexOf("/"));
        }

        const home = Quickshell.env("HOME") || "";
        const xdgPictures = Quickshell.env("XDG_PICTURES_DIR") || "";
        if (xdgPictures)
            return xdgPictures + "/wallpapers";
        if (home)
            return home + "/Pictures/wallpapers";
        return "/tmp";
    }

    signal wallpaperChanged(string path)

    function wallpaperForScreen(screenName) {
        return root.currentWallpaper;
    }

    function setWallpaper(path) {
        if (!path || path === "")
            return;
        WallpaperSettings.update({ wallpaperPath: path });
        root.wallpaperChanged(path);
        if (carouselTimer.running)
            carouselTimer.restart();
    }

    function cycleNext() {
        if (!root.wallpapers.length) {
            root.scanWallpapers();
            return;
        }
        let currentIndex = root.wallpapers.indexOf(root.currentWallpaper);
        let nextIndex = (currentIndex + 1) % root.wallpapers.length;
        root.setWallpaper(root.wallpapers[nextIndex]);
    }

    function cycleRandom() {
        if (!root.wallpapers.length) {
            root.scanWallpapers();
            return;
        }
        if (root.wallpapers.length === 1)
            return;
        let nextIndex = Math.floor(Math.random() * root.wallpapers.length);
        if (root.wallpapers[nextIndex] === root.currentWallpaper)
            nextIndex = (nextIndex + 1) % root.wallpapers.length;
        root.setWallpaper(root.wallpapers[nextIndex]);
    }

    function scanWallpapers() {
        if (root.isScanning) {
            root.rescanRequested = true;
            return;
        }

        root.scanGeneration += 1;
        root.activeScanGeneration = root.scanGeneration;
        root.activeScanDirectory = root.wallpaperDir;
        root.rescanRequested = false;
        root.isScanning = true;
        root.scanError = false;
        scanner.buffer = [];
        scanner.running = true;
    }

    onWallpaperDirChanged: {
        // Do not expose entries from the previous directory while the new
        // scan is in flight.
        root.wallpapers = [];
        root.scanWallpapers();
    }

    Process {
        id: scanner
        property var buffer: []

        command: [
            "sh", "-c",
            "dir=\"$1\"; if [ -d \"$dir\" ]; then find \"$dir\" -maxdepth 1 -type f \\( -iname \"*.jpg\" -o -iname \"*.jpeg\" -o -iname \"*.png\" -o -iname \"*.webp\" -o -iname \"*.bmp\" -o -iname \"*.gif\" \\); else exit 1; fi",
            "_", root.wallpaperDir
        ]
        running: false

        stdout: SplitParser {
            onRead: data => {
                const line = (data || "").trim();
                if (line.length > 0 && WallpaperSource.isImage(line)) {
                    scanner.buffer.push(line);
                }
            }
        }

        onExited: exitCode => {
            root.isScanning = false;
            const sorted = (scanner.buffer || []).slice().sort();
            const uniqueList = [];
            for (let i = 0; i < sorted.length; i++) {
                if (i === 0 || sorted[i] !== sorted[i - 1])
                    uniqueList.push(sorted[i]);
            }

            const isCurrentScan = root.activeScanGeneration === root.scanGeneration
                && root.activeScanDirectory === root.wallpaperDir;
            if (isCurrentScan) {
                root.scanError = exitCode !== 0;
                root.wallpapers = root.scanError ? [] : uniqueList;
                if (root.scanError)
                    console.warn("WallpaperService: wallpaper scan failed with exit code " + exitCode);
            }
            scanner.buffer = [];

            if (root.rescanRequested)
                Qt.callLater(root.scanWallpapers);
        }
    }

    Timer {
        id: carouselTimer
        interval: root.carouselIntervalMinutes * 60 * 1000
        running: root.carouselEnabled && root.wallpapers.length > 1
        repeat: true
        onTriggered: {
            if (root.carouselRandom)
                root.cycleRandom();
            else
                root.cycleNext();
        }
    }

    Component.onCompleted: {
        root.scanWallpapers();
    }
}
