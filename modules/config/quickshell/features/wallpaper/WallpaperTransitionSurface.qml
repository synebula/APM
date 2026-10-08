import QtQuick
import "../../theme"
import "../../ui/animations"
import "../../shared/WallpaperSource.js" as WallpaperSource

Item {
    id: root

    property string sourcePath: ""
    property int transitionDurationMs: 800
    property int fillMode: Image.PreserveAspectCrop
    property bool paused: false

    readonly property bool isColor: WallpaperSource.isSolid(sourcePath)
    property bool isFrontA: true

    function formatUrl(path) {
        if (!path || path === "")
            return "";
        if (WallpaperSource.isSolid(path))
            return "";
        if (path.startsWith("file://") || path.startsWith("http://") || path.startsWith("https://"))
            return path;
        return "file://" + path;
    }

    function switchSource(nextPath) {
        if (!nextPath || nextPath === "")
            return;

        const nextUrl = root.formatUrl(nextPath);
        const nextIsColor = WallpaperSource.isSolid(nextPath);

        if (root.isFrontA) {
            // 当前处于 A，将 B 准备好并淡入
            if (nextIsColor) {
                rectB.color = nextPath;
                imageB.source = "";
                startFadeToB();
            } else {
                rectB.color = "transparent";
                imageB.source = nextUrl;
                if (imageB.status === Image.Ready)
                    startFadeToB();
            }
        } else {
            // 当前处于 B，将 A 准备好并淡入
            if (nextIsColor) {
                rectA.color = nextPath;
                imageA.source = "";
                startFadeToA();
            } else {
                rectA.color = "transparent";
                imageA.source = nextUrl;
                if (imageA.status === Image.Ready)
                    startFadeToA();
            }
        }
    }

    function startFadeToB() {
        fadeAnimation.stop();
        fadeAnimation.targetAOpacity = 0.0;
        fadeAnimation.targetBOpacity = 1.0;
        root.isFrontA = false;
        if (root.transitionDurationMs <= 0) {
            slotA.opacity = 0.0;
            slotB.opacity = 1.0;
            imageA.source = "";
            rectA.color = "transparent";
            return;
        }
        fadeAnimation.start();
    }

    function startFadeToA() {
        fadeAnimation.stop();
        fadeAnimation.targetAOpacity = 1.0;
        fadeAnimation.targetBOpacity = 0.0;
        root.isFrontA = true;
        if (root.transitionDurationMs <= 0) {
            slotA.opacity = 1.0;
            slotB.opacity = 0.0;
            imageB.source = "";
            rectB.color = "transparent";
            return;
        }
        fadeAnimation.start();
    }

    onSourcePathChanged: {
        if (!initialized) {
            // 首次初始化直接呈现
            if (root.isColor) {
                rectA.color = root.sourcePath;
            } else {
                imageA.source = root.formatUrl(root.sourcePath);
            }
            slotA.opacity = 1.0;
            slotB.opacity = 0.0;
            initialized = true;
            return;
        }
        switchSource(sourcePath);
    }

    property bool initialized: false

    ParallelAnimation {
        id: fadeAnimation

        property real targetAOpacity: 1.0
        property real targetBOpacity: 0.0

        FadeAnimation {
            target: slotA
            to: fadeAnimation.targetAOpacity
            duration: Math.round(root.transitionDurationMs * Theme.motion.scale)
            motion: Theme.motion.symmetric
        }

        FadeAnimation {
            target: slotB
            to: fadeAnimation.targetBOpacity
            duration: Math.round(root.transitionDurationMs * Theme.motion.scale)
            motion: Theme.motion.symmetric
        }

        onFinished: {
            // 过渡完成后释放后台图层显存
            if (root.isFrontA) {
                imageB.source = "";
                rectB.color = "transparent";
            } else {
                imageA.source = "";
                rectA.color = "transparent";
            }
        }
    }

    // 插槽 A
    Item {
        id: slotA
        anchors.fill: parent
        opacity: 1.0

        Rectangle {
            id: rectA
            anchors.fill: parent
            color: "transparent"
        }

        AnimatedImage {
            id: imageA
            anchors.fill: parent
            fillMode: root.fillMode
            asynchronous: true
            cache: true
            smooth: true
            paused: root.paused
            onStatusChanged: {
                if (status === Image.Ready && !root.isFrontA && root.initialized)
                    root.startFadeToA();
                else if (status === Image.Error)
                    console.warn("WallpaperTransitionSurface: failed to load image A:", source);
            }
        }
    }

    // 插槽 B
    Item {
        id: slotB
        anchors.fill: parent
        opacity: 0.0

        Rectangle {
            id: rectB
            anchors.fill: parent
            color: "transparent"
        }

        AnimatedImage {
            id: imageB
            anchors.fill: parent
            fillMode: root.fillMode
            asynchronous: true
            cache: true
            smooth: true
            paused: root.paused
            onStatusChanged: {
                if (status === Image.Ready && root.isFrontA && root.initialized)
                    root.startFadeToB();
                else if (status === Image.Error)
                    console.warn("WallpaperTransitionSurface: failed to load image B:", source);
            }
        }
    }

    Component.onCompleted: {
        if (root.sourcePath !== "") {
            if (root.isColor) {
                rectA.color = root.sourcePath;
            } else {
                imageA.source = root.formatUrl(root.sourcePath);
            }
            slotA.opacity = 1.0;
            slotB.opacity = 0.0;
            initialized = true;
        }
    }
}
