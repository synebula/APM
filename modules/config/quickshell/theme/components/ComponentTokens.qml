import QtQuick
import "../colors/runtime"
import "../geometry/runtime"
import "../materials/runtime"

QtObject {
    id: root

    required property ColorTokens colors
    required property real controlScale
    required property real fontScale
    required property bool isDark
    required property ShapeTokens shape
    required property SpacingTokens spacing
    required property real spacingScale
    required property SurfaceTokens _surface

    readonly property SectionHeaderTokens sectionHeader: SectionHeaderTokens {
        controlScale: root.controlScale
    }

    readonly property ArcGaugeTokens arcGauge: ArcGaugeTokens {
        controlScale: root.controlScale
        fontScale: root.fontScale
    }

    readonly property SliderTokens slider: SliderTokens {
        controlScale: root.controlScale
        spacingScale: root.spacingScale
    }

    readonly property PopupTokens popup: PopupTokens {
        colors: root.colors
        controlScale: root.controlScale
        spacing: root.spacing
        surface: root._surface
    }

    readonly property IconButtonTokens iconButton: IconButtonTokens {
        controlScale: root.controlScale
        fontScale: root.fontScale
    }

    readonly property ActionButtonTokens actionButton: ActionButtonTokens {
        colors: root.colors
        controlScale: root.controlScale
        shape: root.shape
        surface: root._surface
    }

    readonly property ActionRowTokens actionRow: ActionRowTokens {
        colors: root.colors
        controlScale: root.controlScale
        shape: root.shape
        spacingScale: root.spacingScale
    }

    readonly property BarButtonTokens barButton: BarButtonTokens {
        colors: root.colors
        controlScale: root.controlScale
        spacing: root.spacing
    }

    readonly property ToggleSwitchTokens toggleSwitch: ToggleSwitchTokens {
        colors: root.colors
    }

    readonly property BarGroupTokens barGroup: BarGroupTokens {
        controlScale: root.controlScale
        shape: root.shape
        spacingScale: root.spacingScale
        surface: root._surface
    }

    readonly property BarTokens bar: BarTokens {
        controlScale: root.controlScale
        spacingScale: root.spacingScale
    }

    readonly property StatusTokens status: StatusTokens {
        colors: root.colors
    }

    readonly property CalendarTokens calendar: CalendarTokens {
        colors: root.colors
    }

    readonly property ThemeCardTokens themeCard: ThemeCardTokens {
        colors: root.colors
    }

    readonly property ColorModeToggleTokens colorModeToggle: ColorModeToggleTokens {
        colors: root.colors
    }

    readonly property BluetoothTokens bluetooth: BluetoothTokens {
        colors: root.colors
    }

    readonly property MenuTokens menu: MenuTokens {
        spacing: root.spacing
    }

    readonly property NotificationTokens notification: NotificationTokens {
        colors: root.colors
        controlScale: root.controlScale
        isDark: root.isDark
        surface: root._surface
    }
}
