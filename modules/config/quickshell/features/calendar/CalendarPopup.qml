pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import Quickshell

import "../../theme"
import "../../ui/containers"
import "../../ui/controls"

PopupPanel {
    id: root
    property date displayedMonth: new Date()
    contentWidth: 280 * Theme.controlScale
    contentHeight: content.implicitHeight + Theme.components.popup.padding * 2
    onOpened: root.displayedMonth = clock.date

    function shiftMonth(delta) {
        root.displayedMonth = new Date(root.displayedMonth.getFullYear(), root.displayedMonth.getMonth() + delta, 1);
    }

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }
    WheelHandler {
        onWheel: event => {
            if (event.angleDelta.y)
                root.shiftMonth(event.angleDelta.y > 0 ? -1 : 1);
        }
    }

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: Theme.components.popup.padding
        spacing: Theme.spacing.medium
        SectionHeader {
            Layout.fillWidth: true
            title: Qt.formatDateTime(root.displayedMonth, "yyyy年 M月")
            IconButton {
                glyph: "󰃭"
                tooltipText: "回到今天"
                onClicked: root.displayedMonth = clock.date
            }
            IconButton {
                glyph: ""
                tooltipText: "上个月"
                onClicked: root.shiftMonth(-1)
            }
            IconButton {
                glyph: ""
                tooltipText: "下个月"
                onClicked: root.shiftMonth(1)
            }
        }
        Divider {
            Layout.fillWidth: true
        }
        Controls.DayOfWeekRow {
            Layout.fillWidth: true
            locale: Qt.locale("zh_CN")
            spacing: Theme.spacing.small
            delegate: TextLabel {
                required property string shortName
                text: shortName
                font: Theme.typography.caption
                color: Theme.colors.textSecondary
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
        Controls.MonthGrid {
            id: monthGrid
            Layout.fillWidth: true
            Layout.preferredHeight: Theme.components.actionRow.height * 6
            locale: Qt.locale("zh_CN")
            month: root.displayedMonth.getMonth()
            year: root.displayedMonth.getFullYear()
            spacing: Theme.spacing.small
            delegate: Rectangle {
                id: day
                required property var model
                radius: Theme.shape.controlRadius
                color: Theme.components.calendar.dayBackground(model.today, hover.hovered)
                HoverHandler {
                    id: hover
                }
                TextLabel {
                    anchors.centerIn: parent
                    text: day.model.day
                    font.bold: day.model.today
                    opacity: day.model.month === monthGrid.month ? 1 : 0.35
                    color: Theme.components.calendar.dayForeground(day.model.today)
                }
            }
        }
        Divider {
            Layout.fillWidth: true
        }
        TextLabel {
            Layout.fillWidth: true
            text: Qt.formatDateTime(clock.date, "yyyy年MM月dd日 dddd HH:mm")
            font: Theme.typography.caption
            color: Theme.colors.textSecondary
        }
    }
}
