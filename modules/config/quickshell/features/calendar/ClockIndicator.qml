pragma ComponentBehavior: Bound
import "../../config"
import "../../ui/controls"
import QtQuick
import Quickshell

BarButton {
    id: root

    property var barWindow: null
    property Item anchorItem: root
    property bool showDetailedDate: false

    function toggleCalendar() {
        if (!calendarLoader.active) {
            calendarLoader.active = true;
            if (calendarLoader.item)
                calendarLoader.item.open();
        } else if (calendarLoader.item) {
            calendarLoader.item.toggle();
        }
    }

    onClicked: root.toggleCalendar()
    onRightClicked: root.showDetailedDate = !root.showDetailedDate
    tooltipText: Qt.formatDateTime(clock.date, "dddd, MMMM d, yyyy") + " (左键: 日历 // 右键: 切换格式)"

    SystemClock {
        id: clock

        precision: SystemClock.Minutes
    }

    Loader {
        id: calendarLoader
        active: false
        sourceComponent: Component {
            CalendarPopup {
                anchorItem: root.anchorItem
                barWindow: root.barWindow
            }
        }
    }

    content: BarText {
        anchors.verticalCenter: parent ? parent.verticalCenter : undefined
        color: root.foreground
        text: Qt.formatDateTime(clock.date, root.showDetailedDate ? ShellSettings.clockDetailedFormat : ShellSettings.clockFormat)
    }
}
