import "../theme"
import "../ui/controls"
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
        compare(barLabel.font.pixelSize, Theme.typography.bodySize);
        compare(barLabel.font.family, Theme.typography.family);
        verify(barLabel.font.bold);
        ThemeController.setScale("fontScale", 1);
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
