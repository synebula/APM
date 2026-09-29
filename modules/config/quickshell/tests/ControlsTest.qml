import "../theme/appearance"
import "../theme"
import "../theme/typography"
import "../theme/colors/runtime/ColorMath.js" as ColorMath
import "../ui/controls"
import "../ui/charts"
import "../ui/containers"
import "../features/notifications"
import QtQuick
import QtQuick.Window

TestSuite {
    id: root

    property int clicks: 0
    property int rightClicks: 0
    property int middleClicks: 0

    function init() {
        root.clicks = 0;
        root.rightClicks = 0;
        root.middleClicks = 0;
        button.enabled = true;
        button.primary = false;
        button.checked = false;
        button.checkable = false;
        button.destructive = false;
        toggle.checked = false;
        slider.value = 0.5;
    }

    function test_buttonSupportsPointerKeyboardAndDisabledState() {
        mouseClick(button);
        compare(root.clicks, 1);
        button.forceActiveFocus();
        keyClick(Qt.Key_Space);
        compare(root.clicks, 2);
        button.enabled = false;
        mouseClick(button);
        compare(root.clicks, 2);
    }

    Component {
        id: interactiveCardComponent
        InteractiveCard {
            x: 20; y: 345; width: 160; height: 48
            property int activations: 0
            checkable: true
            onClicked: activations++
            contentItem: TextLabel { text: "Card" }
        }
    }

    function test_cardSupportsPointerKeyboardAndRetainsMaterialWhenSelected() {
        const card = createTemporaryObject(interactiveCardComponent, root);
        verify(card !== null);
        mouseClick(card);
        compare(card.activations, 1);
        verify(card.checked);
        verify(card.background.materialEnabled);
        card.forceActiveFocus();
        keyClick(Qt.Key_Space);
        compare(card.activations, 2);
        verify(!card.checked);
        card.enabled = false;
        mouseClick(card);
        compare(card.activations, 2);
    }

    function test_barButtonPreservesThreeMouseActions() {
        mouseClick(barButton, barButton.width / 2, barButton.height / 2, Qt.LeftButton);
        mouseClick(barButton, barButton.width / 2, barButton.height / 2, Qt.RightButton);
        mouseClick(barButton, barButton.width / 2, barButton.height / 2, Qt.MiddleButton);
        compare(root.clicks, 1);
        compare(root.rightClicks, 1);
        compare(root.middleClicks, 1);
    }

    function test_sliderDragAndKeyboard() {
        mouseDrag(slider, slider.width / 2, slider.height / 2, slider.width * 0.4, 0);
        verify(slider.value > 0.8);
        const previous = slider.value;
        slider.forceActiveFocus();
        keyClick(Qt.Key_Left);
        verify(slider.value < previous);
    }

    function test_switchSupportsKeyboardAndRowFitsText() {
        toggle.forceActiveFocus();
        keyClick(Qt.Key_Space);
        verify(toggle.checked);
        verify(row.height >= row.contentItem.implicitHeight + row.topPadding + row.bottomPadding);
    }

    function test_themeFontReachesDerivedLabels() {
        verify(ThemeController.setScale("fontScale", 1.5));
        compare(barLabel.font.pixelSize, Theme.typography.body.pixelSize);
        compare(barLabel.font.family, Theme.typography.body.family);
        compare(barLabel.font.weight, Theme.typography.title.weight);
        ThemeController.setScale("fontScale", 1);
    }

    function test_controlsInheritUnifiedTextColor() {
        compare(barButton.foreground.toString(), Theme.colors.textPrimary.toString());
        compare(button.foreground.toString(), Theme.colors.textPrimary.toString());
        compare(row.foreground.toString(), Theme.colors.textPrimary.toString());
        compare(barLabel.color.toString(), Theme.colors.textPrimary.toString());
    }

    function test_filledButtonContrast_data() {
        const rows = [];
        for (const theme of ["flat", "neumorphic", "frosted-glass", "liquid-glass"])
            for (const mode of ["light", "dark"])
                for (const variant of ["primary", "selected", "destructive"])
                    rows.push({ tag: theme + "/" + mode + "/" + variant, theme: theme, mode: mode, variant: variant });
        return rows;
    }

    function test_cardMaterials_data() {
        const rows = [];
        for (const theme of ["flat", "neumorphic", "frosted-glass", "liquid-glass"])
            for (const mode of ["light", "dark"])
                rows.push({ tag: theme + "/" + mode, theme: theme, mode: mode });
        return rows;
    }

    Component {
        id: notificationCardComponent
        NotificationCard {
            x: 20
            y: 300
            width: 300
            height: 110
            notification: null
            toastMode: true
            hoverEnabled: false
        }
    }

    function test_cardMaterials(data) {
        const oldTheme = Theme.definition.themeId;
        const oldMode = Theme.colorMode;
        try {
            ThemeController.setTheme(data.theme);
            ThemeController.setColorMode(data.mode);
            const card = createTemporaryObject(notificationCardComponent, root);
            verify(card !== null);
            verify(card.background.materialEnabled, "An opaque card color must retain its material");
            compare(card.background.highlightEnabled, data.theme !== "flat");
            compare(!!card.background.gradient, ["neumorphic", "liquid-glass"].includes(data.theme));
            compare(card.background.layer.enabled, data.theme === "neumorphic");
            const alpha = Qt.rgba(0, 0, 0, Theme.surface.fillOpacity).a;
            tryCompare(card.background, "color", Qt.rgba(card.fillColor.r, card.fillColor.g, card.fillColor.b, alpha));
            if (data.theme === "frosted-glass") {
                const canvas = root.Window.window.contentItem;
                const point = card.mapToItem(canvas, card.width / 2, 0);
                const brightness = c => c.r + c.g + c.b;
                tryVerify(() => {
                    const pixels = grabImage(canvas);
                    const top = pixels.pixel(Math.round(point.x), Math.round(point.y + 1));
                    const inside = pixels.pixel(Math.round(point.x), Math.round(point.y + 5));
                    const bottom = pixels.pixel(Math.round(point.x), Math.round(point.y + card.height - 2));
                    return brightness(top) > brightness(inside) + 0.02
                        && brightness(bottom) < brightness(inside) - 0.02;
                }, 3000, "Frosted cards must render the bright top rim and dark bottom rim");
            }
        } finally {
            ThemeController.setTheme(oldTheme);
            ThemeController.setColorMode(oldMode);
        }
    }

    function test_barSemanticFill_data() { return test_cardMaterials_data(); }

    function test_barSemanticFill(data) {
        const oldTheme = Theme.definition.themeId;
        const oldMode = Theme.colorMode;
        try {
            ThemeController.setTheme(data.theme);
            ThemeController.setColorMode(data.mode);
            for (const state of ["active", "urgent"]) {
                barButton.active = state === "active";
                barButton.urgent = state === "urgent";
                verify(!barButton.background.materialEnabled);
                tryVerify(() => barButton.background.color.toString() === barButton.fillColor.toString());
                verify(ColorMath.contrast(barButton.fillColor, barButton.foreground) >= 4.5);
            }
        } finally {
            barButton.active = false;
            barButton.urgent = false;
            ThemeController.setTheme(oldTheme);
            ThemeController.setColorMode(oldMode);
        }
    }

    function test_filledButtonContrast(data) {
        const oldTheme = Theme.definition.themeId;
        const oldMode = Theme.colorMode;
        const control = button;
        const oldHoverEnabled = control.hoverEnabled;
        try {
            verify(ThemeController.setTheme(data.theme));
            verify(ThemeController.setColorMode(data.mode));
            root.forceActiveFocus();
            control.hoverEnabled = false;
            control.primary = data.variant !== "selected";
            control.checkable = data.variant === "selected";
            control.checked = data.variant === "selected";
            control.destructive = data.variant === "destructive";
            const canvas = root.Window.window.contentItem;
            const point = control.mapToItem(canvas, control.width / 2, control.height - 4);
            let fill;
            // Capture the window at mapped coordinates and wait for the color transition to settle.
            tryVerify(() => {
                const pixels = grabImage(canvas);
                fill = pixels.pixel(Math.round(point.x), Math.round(point.y));
                return fill.toString() === control.fillColor.toString();
            }, 3000, data.tag + " resolved fill must reach the rendered button");
            compare(fill.a, 1);
            compare(fill.toString(), control.fillColor.toString(), "Rendered semantic fill");
            verify(ColorMath.contrast(fill, control.foreground) >= 4.5,
                data.tag + " rendered contrast: pixel=" + fill + " foreground=" + control.foreground
                + " fill=" + control.fillColor + " material=" + control.background.materialEnabled
                + " active=" + Theme.definition.themeId + "/" + Theme.resolvedColorMode);
            verify(!control.background.gradient, "Semantic fills must retain their resolved color");
        } finally {
            control.hoverEnabled = oldHoverEnabled;
            ThemeController.setTheme(oldTheme);
            ThemeController.setColorMode(oldMode);
        }
    }

    Component {
        id: typographyFixture
        Item {
            property TypographySpec style: TypographySpec {
                body { family: "serif"; italic: true; letterSpacing: 1; wordSpacing: 2 }
                title { family: "monospace"; pixelSize: 18; weight: Font.DemiBold }
            }
            property alias plain: plain
            property alias bar: bar
            property alias header: header
            property alias selectedRow: selectedRow
            TextLabel { id: plain; text: "Body" }
            BarText { id: bar; y: 30; text: "Bar" }
            SectionHeader { id: header; y: 60; width: 260; title: "Title" }
            ActionRow { id: selectedRow; y: 100; width: 260; text: "Selected"; selected: true }
        }
    }

    function test_fontRolesReachActualControlsAndSurviveEmphasis() {
        const fixture = createTemporaryObject(typographyFixture, root);
        verify(fixture !== null);
        const definition = Theme.definition;
        const original = definition.typography;
        try {
            definition.typography = fixture.style;
            compare(fixture.plain.font.family, "serif");
            verify(fixture.plain.font.italic);
            compare(fixture.plain.font.letterSpacing, 1);
            compare(fixture.plain.font.wordSpacing, 2);
            verify(fixture.bar.font.italic);
            compare(fixture.bar.font.wordSpacing, 2);
            compare(fixture.bar.font.weight, Font.DemiBold);
            const title = findChild(fixture.header, "sectionTitle");
            verify(title !== null);
            compare(title.font.family, "monospace");
            compare(title.font.pixelSize, Theme.typography.title.pixelSize);
            compare(title.font.weight, Font.DemiBold);
            const selectedTitle = findChild(fixture.selectedRow, "actionRowTitle");
            verify(selectedTitle !== null);
            verify(selectedTitle.font.italic);
            compare(selectedTitle.font.letterSpacing, 1);
            compare(selectedTitle.font.weight, Font.DemiBold);
            fixture.style.body.wordSpacing = 3;
            compare(fixture.plain.font.wordSpacing, 3);
            compare(selectedTitle.font.wordSpacing, 3);
            compare(fixture.style.body.weight, Font.Normal);
        } finally {
            definition.typography = original;
        }
    }

    Component {
        id: independentSizes

        Item {
            property alias header: header
            property alias gauge: gauge
            property alias button: button

            SectionHeader {
                id: header
                width: 240
                title: "Header"
                glyph: "●"
            }

            ArcGauge { id: gauge; y: 50 }
            ActionButton { id: button; y: 90 }
        }
    }

    function test_componentSizesDoNotFollowUnrelatedControls() {
        const fixture = createTemporaryObject(independentSizes, root);
        verify(fixture !== null);
        tryCompare(fixture.header, "implicitHeight", Theme.components.sectionHeader.iconContainerSize);
        const headerHeight = fixture.header.implicitHeight;
        const gaugeWidth = fixture.gauge.implicitWidth;
        const buttonHeight = fixture.button.implicitHeight;
        try {
            Theme.components.actionRow.controlScale = Theme.controlScale * 2;
            Theme.components.barButton.controlScale = Theme.controlScale * 2;
            wait(0);
            compare(fixture.header.implicitHeight, headerHeight);
            compare(fixture.gauge.implicitWidth, gaugeWidth);
            compare(fixture.button.implicitHeight, buttonHeight);
        } finally {
            Theme.components.actionRow.controlScale = Qt.binding(() => Theme.controlScale);
            Theme.components.barButton.controlScale = Qt.binding(() => Theme.controlScale);
        }
    }

    name: "Controls"
    visible: true
    when: root.Window.window !== null && root.Window.window.visible
    width: 600
    height: 420

    ActionButton {
        id: button

        x: 20
        y: 20
        text: "Action"
        onClicked: root.clicks++
    }

    BarButton {
        id: barButton

        x: 20
        y: 80
        onClicked: root.clicks++
        onRightClicked: root.rightClicks++
        onMiddleClicked: root.middleClicks++

        content: BarText {
            id: barLabel

            text: "Bar action"
        }
    }

    ValueSlider {
        id: slider

        x: 20
        y: 140
        width: 240
    }

    ToggleSwitch {
        id: toggle

        x: 20
        y: 200
    }

    ActionRow {
        id: row

        x: 20
        y: 250
        width: 300
        text: "Device"
        description: "Description"
    }
}
