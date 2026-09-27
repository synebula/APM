import "../features/wallpaper"
import "../shared/lib/wallpaper/WallpaperSource.js" as WallpaperSource
import QtQuick
import Quickshell

TestSuite {
    id: root

    name: "Wallpaper"

    readonly property string gifPath: (Quickshell.env("XDG_STATE_HOME") || "/tmp") + "/test_wallpaper.gif"

    function test_wallpaperSourceClassification() {
        compare(WallpaperSource.kind("#1e1e2e"), "solid");
        compare(WallpaperSource.kind("#ffffff00"), "solid");
        compare(WallpaperSource.kind("/home/alex/wallpaper.jpg"), "image");
        compare(WallpaperSource.kind("/home/alex/wallpaper.png"), "image");
        compare(WallpaperSource.kind("/home/alex/wallpaper.webp"), "image");
        compare(WallpaperSource.kind("/home/alex/wallpaper.gif"), "image");
        compare(WallpaperSource.kind("file:///home/alex/wallpaper.GIF"), "image");
        compare(WallpaperSource.isImage("/path/to/animation.gif"), true);
        compare(WallpaperSource.isSolid("#1e1e2e"), true);
        compare(WallpaperSource.kind("not_a_path"), "invalid");
        compare(WallpaperSource.kind(""), "empty");
    }

    function test_wallpaperTransitionSurfaceHandlesGifAndPause() {
        surface.sourcePath = root.gifPath;
        tryVerify(() => surface.initialized);
        surface.paused = true;
        compare(surface.paused, true);
        surface.paused = false;
        compare(surface.paused, false);
    }

    function test_wallpaperTransitionSwitching() {
        surface.sourcePath = "#112233";
        tryVerify(() => surface.sourcePath === "#112233");
        surface.sourcePath = root.gifPath;
        tryVerify(() => surface.sourcePath === root.gifPath);
    }

    WallpaperTransitionSurface {
        id: surface
        width: 100
        height: 100
        transitionDurationMs: 0
    }
}
