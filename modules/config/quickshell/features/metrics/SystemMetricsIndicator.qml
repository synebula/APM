import "../../services"
import "../../theme"
import "../../ui/IconGlyphs.js" as IconGlyphs
import "../../ui/charts"
import "../../ui/controls"
import "./MetricFormat.js" as MetricFormat
import QtQuick

// ============================================================================
// SystemMetricsIndicator (硬件状态微件)
// 集成 ArcGauge 环形仪表盘与 MetricFormat 格式化工具，兼顾紧凑视觉与数值可读性
// ============================================================================
Row {
    id: root

    property bool showMemoryBytes: false

    spacing: Theme.components.bar.padding

    // CPU 占用率仪表盘
    BarButton {
        tooltipText: "CPU: " + MetricFormat.percent(SystemMetricsService.cpuPercent, 0)

        content: Row {
            spacing: Theme.spacing.small
            anchors.verticalCenter: parent.verticalCenter

            ArcGauge {
                anchors.verticalCenter: parent.verticalCenter
                value: SystemMetricsService.cpuPercent / 100
                glyph: "󰍛"
                progressColor: SystemMetricsService.cpuPercent > 80 ? Theme.colors.danger : Theme.colors.accent
            }

            BarText {
                anchors.verticalCenter: parent.verticalCenter
                text: MetricFormat.percent(SystemMetricsService.cpuPercent, 0)
            }
        }
    }

    // 核心温度仪表盘
    BarButton {
        tooltipText: "Temperature: " + MetricFormat.temperature(SystemMetricsService.temperatureCelsius, false)

        content: Row {
            spacing: Theme.spacing.small
            anchors.verticalCenter: parent.verticalCenter

            ArcGauge {
                anchors.verticalCenter: parent.verticalCenter
                value: Math.max(0, Math.min(1, (SystemMetricsService.temperatureCelsius - 30) / 70))
                glyph: IconGlyphs.temperature(SystemMetricsService.temperatureCelsius)
                progressColor: SystemMetricsService.temperatureCelsius > 80 ? Theme.colors.danger : Theme.colors.accent
            }

            BarText {
                anchors.verticalCenter: parent.verticalCenter
                text: MetricFormat.temperature(SystemMetricsService.temperatureCelsius, false)
            }
        }
    }

    // 内存占用率仪表盘 (支持点击在百分比与具体容量间切换)
    BarButton {
        tooltipText: "Memory: " + MetricFormat.bytes(SystemMetricsService.memoryUsedBytes) + " / " + MetricFormat.bytes(SystemMetricsService.memoryTotalBytes)
        onClicked: root.showMemoryBytes = !root.showMemoryBytes

        content: Row {
            spacing: Theme.spacing.small
            anchors.verticalCenter: parent.verticalCenter

            ArcGauge {
                anchors.verticalCenter: parent.verticalCenter
                value: SystemMetricsService.memoryPercent / 100
                glyph: ""
                progressColor: SystemMetricsService.memoryPercent > 85 ? Theme.colors.danger : Theme.colors.accent
            }

            BarText {
                anchors.verticalCenter: parent.verticalCenter
                text: root.showMemoryBytes ? MetricFormat.bytes(SystemMetricsService.memoryUsedBytes) : MetricFormat.percent(SystemMetricsService.memoryPercent, 0)
            }
        }
    }
}
