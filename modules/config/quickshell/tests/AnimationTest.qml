import QtQuick
import "../theme"
import "../theme/appearance"
import "../theme/motion"
import "../ui/animations"

TestSuite {
    id: root
    name: "Animation"

    Component { id: fadeComponent; FadeAnimation {} }
    Component { id: slideComponent; SlideAnimation {} }
    Component { id: scaleComponent; ScaleAnimation {} }
    Component { id: bounceComponent; BounceAnimation {} }
    Component { id: colorComponent; ThemeColorAnimation {} }
    Component { id: customMotionComponent; MotionSpec { duration: 101.5; easing: Easing.Linear } }

    Component {
        id: fixtureComponent
        Rectangle {
            width: 240
            height: 160
            color: Theme.colors.background
            property alias tile: tile
            property alias offset: offset
            Rectangle {
                id: tile
                anchors.centerIn: parent
                width: 48
                height: 48
                color: Theme.colors.accent
                transform: Translate { id: offset }
            }
        }
    }

    function test_interpolatesAndFinishes_data() {
        return [
            { tag: "fade-in", component: fadeComponent, property: "opacity", from: 0, to: 1 },
            { tag: "fade-out", component: fadeComponent, property: "opacity", from: 1, to: 0 },
            { tag: "slide-left", component: slideComponent, property: "x", from: -48, to: 0, translate: true },
            { tag: "slide-right", component: slideComponent, property: "x", from: 48, to: 0, translate: true },
            { tag: "slide-up", component: slideComponent, property: "y", from: 48, to: 0, translate: true },
            { tag: "slide-down", component: slideComponent, property: "y", from: -48, to: 0, translate: true },
            { tag: "scale-in", component: scaleComponent, property: "scale", from: 0.5, to: 1 },
            { tag: "scale-out", component: scaleComponent, property: "scale", from: 1, to: 0.5 },
            { tag: "bounce", component: bounceComponent, property: "y", from: -48, to: 0, translate: true }
        ];
    }

    function test_interpolatesAndFinishes(data) {
        const fixture = createTemporaryObject(fixtureComponent, root);
        const target = data.translate ? fixture.offset : fixture.tile;
        const animation = createTemporaryObject(data.component, root, {
            target: target, property: data.property, from: data.from, to: data.to, duration: 180
        });
        verify(animation !== null);
        const originalX = fixture.tile.x;
        const originalY = fixture.tile.y;
        animation.start();
        tryVerify(() => target[data.property] > Math.min(data.from, data.to)
            && target[data.property] < Math.max(data.from, data.to), 1000);
        tryCompare(animation, "running", false);
        compare(target[data.property], data.to);
        compare(fixture.tile.x, originalX, "Animations must preserve the anchored layout");
        compare(fixture.tile.y, originalY);
    }

    Component {
        id: behaviorComponent
        Rectangle {
            width: 40
            height: 40
            color: Theme.colors.accent
            property bool revealed: false
            opacity: revealed ? 1 : 0
            Behavior on opacity { FadeAnimation { duration: 300 } }
        }
    }

    function test_behaviorReversesFromCurrentValueAndRenders() {
        const tile = createTemporaryObject(behaviorComponent, root);
        const hiddenImage = grabImage(tile);
        tile.revealed = true;
        tryVerify(() => tile.opacity > 0 && tile.opacity < 1, 1000);
        const previous = tile.opacity;
        tile.revealed = false;
        verify(Math.abs(tile.opacity - previous) < 0.01, "Reversal must not jump to a fixed endpoint");
        tryCompare(tile, "opacity", 0);
        tile.revealed = true;
        tryCompare(tile, "opacity", 1);
        verify(!grabImage(tile).equals(hiddenImage), "Fade must change rendered pixels");
    }

    Component {
        id: groupComponent
        ParallelAnimation {
            id: group
            required property Item tile
            required property QtObject offset
            FadeAnimation { target: group.tile; from: 0; to: 1; duration: 100 }
            SlideAnimation { target: group.offset; from: 30; to: 0; duration: 100 }
            ScaleAnimation { target: group.tile; from: 0.7; to: 1; duration: 100 }
        }
    }

    function test_parallelCompositionCanReplay() {
        const fixture = createTemporaryObject(fixtureComponent, root);
        const group = createTemporaryObject(groupComponent, root, { tile: fixture.tile, offset: fixture.offset });
        verify(group !== null);
        for (let i = 0; i < 2; ++i) {
            group.restart();
            tryCompare(group, "running", false);
            compare(fixture.tile.opacity, 1);
            compare(fixture.tile.scale, 1);
            compare(fixture.offset.y, 0);
        }
    }

    function test_stopPreservesCurrentValueAndRestartReplays() {
        const fixture = createTemporaryObject(fixtureComponent, root);
        const animation = createTemporaryObject(slideComponent, root, {
            target: fixture.offset, from: 80, to: 0, duration: 300
        });
        animation.start();
        tryVerify(() => fixture.offset.y > 0 && fixture.offset.y < 80);
        animation.stop();
        const stoppedAt = fixture.offset.y;
        wait(40);
        compare(fixture.offset.y, stoppedAt);
        animation.restart();
        tryCompare(animation, "running", false);
        compare(fixture.offset.y, 0);
    }

    function test_bounceChangesDirectionAndSettles() {
        const fixture = createTemporaryObject(fixtureComponent, root);
        const animation = createTemporaryObject(bounceComponent, root, {
            target: fixture.offset, from: -60, to: 0, duration: 400
        });
        compare(animation.easing.type, Easing.OutBounce);
        let previous = -60;
        let reversed = false;
        const sample = () => {
            if (fixture.offset.y < previous - 0.01)
                reversed = true;
            previous = fixture.offset.y;
        };
        fixture.offset.yChanged.connect(sample);
        animation.start();
        tryCompare(animation, "running", false);
        fixture.offset.yChanged.disconnect(sample);
        verify(reversed, "Bounce must visibly reverse direction before settling");
        compare(fixture.offset.y, 0);
    }

    function test_themeScaleAndDisabledMotion_data() {
        return [
            { tag: "fade", component: fadeComponent, property: "opacity", role: "standard", from: 0, to: 1 },
            { tag: "slide", component: slideComponent, property: "y", role: "standard", from: 40, to: 0 },
            { tag: "scale", component: scaleComponent, property: "scale", role: "standard", from: 0.5, to: 1 },
            { tag: "bounce", component: bounceComponent, property: "y", role: "bounce", from: -40, to: 0 }
        ];
    }

    function test_themeScaleAndDisabledMotion(data) {
        const oldScale = Theme.motion.scale;
        const oldTheme = Theme.definition.themeId;
        const fixture = createTemporaryObject(fixtureComponent, root);
        const target = data.property === "y" ? fixture.offset : fixture.tile;
        const animation = createTemporaryObject(data.component, root, {
            target: target, from: data.from, to: data.to
        });
        try {
            ThemeController.setMotionScale(1);
            ThemeController.setTheme("flat");
            const normalDuration = animation.duration;
            verify(normalDuration > 0);
            ThemeController.setMotionScale(2);
            verify(Math.abs(animation.duration - normalDuration * 2) <= 1);
            ThemeController.setTheme("liquid-glass");
            compare(animation.duration, Theme.motion[data.role].duration);
            verify(animation.duration > normalDuration * 2);
            ThemeController.setMotionScale(0);
            animation.start();
            compare(animation.running, false);
            compare(target[data.property], data.to, "Disabled motion must immediately reach its final value");
        } finally {
            ThemeController.setTheme(oldTheme);
            ThemeController.setMotionScale(oldScale);
        }
    }

    function test_presetChangesReachCommonAndSpecializedAnimations() {
        const profile = Theme.definition.motion;
        const oldBounce = profile.bounce;
        const oldScale = Theme.motion.scale;
        const fixture = createTemporaryObject(fixtureComponent, root);
        const customMotion = createTemporaryObject(customMotionComponent, root);
        const bounce = createTemporaryObject(bounceComponent, root, { target: fixture.offset, from: -40, to: 0 });
        const fade = createTemporaryObject(fadeComponent, root, {
            motion: Theme.motion.bounce, target: fixture.tile, from: 0, to: 1, durationMultiplier: 3
        });
        try {
            ThemeController.setMotionScale(1.5);
            profile.bounce = customMotion;
            compare(bounce.duration, 152);
            compare(fade.duration, 456);
            compare(bounce.easing.type, Easing.Linear);
            compare(fade.easing.type, Easing.Linear);
            ThemeController.setMotionScale(0);
            bounce.start();
            fade.start();
            compare(fixture.offset.y, 0);
            compare(fixture.tile.opacity, 1);
            verify(!bounce.running && !fade.running);
        } finally {
            profile.bounce = oldBounce;
            ThemeController.setMotionScale(oldScale);
        }
    }

    function test_colorTransitionUsesThemeAndFinishesWhenDisabled() {
        const fixture = createTemporaryObject(fixtureComponent, root);
        const animation = createTemporaryObject(colorComponent, root, {
            target: fixture.tile, property: "color", from: "black", to: "white"
        });
        const oldScale = Theme.motion.scale;
        try {
            ThemeController.setMotionScale(1);
            animation.start();
            tryVerify(() => fixture.tile.color.r > 0 && fixture.tile.color.r < 1);
            tryCompare(animation, "running", false);
            compare(fixture.tile.color.toString(), "#ffffff");
            ThemeController.setMotionScale(0);
            animation.to = "black";
            animation.restart();
            compare(animation.running, false);
            compare(fixture.tile.color.toString(), "#000000");
        } finally {
            ThemeController.setMotionScale(oldScale);
        }
    }
}
