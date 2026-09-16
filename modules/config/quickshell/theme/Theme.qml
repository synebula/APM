pragma ComponentBehavior: Bound
pragma Singleton
import QtQuick
import Quickshell

import "../config"
import "./ColorMath.js" as ColorMath

Singleton {
    id: root

    readonly property ThemeDefinition definition: ThemeCatalog.find(AppearanceSettings.themeId) || ThemeCatalog.defaultTheme
    readonly property PaletteDefinition palette: PaletteCatalog.find(AppearanceSettings.paletteId) || PaletteCatalog.defaultPalette
    readonly property string colorMode: ["system", "light", "dark"].includes(AppearanceSettings.colorMode) ? AppearanceSettings.colorMode : "system"
    readonly property string resolvedColorMode: root.colorMode === "system" ? ColorModeResolver.systemMode : root.colorMode
    readonly property PaletteVariant paletteVariant: PaletteCatalog.variant(root.palette.paletteId, root.resolvedColorMode)
    readonly property string displayName: root.definition.displayName
    readonly property string accentId: PaletteCatalog.accentIds(root.paletteVariant).includes(AppearanceSettings.accentId) ? AppearanceSettings.accentId : root.paletteVariant.defaultAccentId
    readonly property bool accentCustomized: root.accentId !== root.paletteVariant.defaultAccentId
    readonly property real fontScale: Math.max(0.75, Math.min(2, AppearanceSettings.fontScale))
    readonly property real spacingScale: Math.max(0.5, Math.min(2, AppearanceSettings.spacingScale))
    readonly property real controlScale: Math.max(root.fontScale, root.spacingScale)

    readonly property ColorTokens colors: ColorTokens {}

    readonly property TypographyTokens typography: TypographyTokens {}

    readonly property SpacingTokens spacing: SpacingTokens {}

    readonly property ShapeTokens shape: ShapeTokens {}

    readonly property MotionTokens motion: MotionTokens {
        baseDuration: root.definition.motion.duration
        scale: Math.max(0, Math.min(4, AppearanceSettings.motionScale))
    }

    readonly property ComponentTokens components: ComponentTokens {}

    component SliderTokens: QtObject {
        readonly property int height: Math.round(20 * root.controlScale)
        readonly property int trackHeight: Math.round(6 * root.spacingScale)
        readonly property int handleSize: Math.round(14 * root.controlScale)
    }

    component PopupTokens: QtObject {
        readonly property int padding: root.spacing.large
        readonly property int gap: root.spacing.small

        function swatchBorderColor(selected: bool, visualFocus: bool): color {
            return (selected || visualFocus) ? root.colors.textPrimary : root.colors.outline;
        }
    }

    component IconButtonTokens: QtObject {
        readonly property int size: Math.round(28 * root.controlScale)
        readonly property int compactSize: Math.round(22 * root.controlScale)
        readonly property int iconSize: Math.round(14 * root.fontScale)
    }

    component ActionButtonTokens: QtObject {
        readonly property int height: Math.round(32 * root.controlScale)

        function background(enabled: bool, checked: bool, primary: var, tonal: var, destructive: var): color {
            if (!enabled)
                return root.colors.disabledSurface;
            if (destructive && (primary || checked))
                return root.colors.danger;
            if (destructive && tonal)
                return root.colors.dangerContainer;
            if (primary || checked)
                return root.colors.accent;
            if (tonal)
                return root.colors.accentContainer;
            return Qt.color("transparent");
        }

        function foreground(enabled: bool, checked: bool, primary: var, tonal: var, destructive: var): color {
            if (!enabled)
                return root.colors.disabledText;
            if (destructive && (primary || checked))
                return root.colors.dangerForeground;
            if (primary || checked)
                return root.colors.accentForeground;
            if (destructive)
                return root.colors.danger;
            if (tonal)
                return root.colors.accent;
            return root.colors.textPrimary;
        }

        function borderColor(visualFocus: bool, checked: bool, destructive: var): color {
            if (visualFocus)
                return destructive ? root.colors.danger : root.colors.focusRing;
            if (checked)
                return destructive ? root.colors.danger : root.colors.accent;
            return Qt.color("transparent");
        }
    }

    component ActionRowTokens: QtObject {
        readonly property int height: Math.round(32 * root.controlScale)
        readonly property int padding: Math.round(10 * root.spacingScale)

        function background(enabled: bool, selected: bool, destructive: var): color {
            if (selected)
                return destructive ? root.colors.dangerContainer : root.colors.selectedSurface;
            return Qt.color("transparent");
        }

        function foreground(enabled: bool, selected: bool, destructive: bool): color {
            if (!enabled)
                return root.colors.disabledText;
            if (destructive)
                return root.colors.danger;
            if (selected)
                return root.colors.accent;
            return root.colors.textPrimary;
        }

        function borderColor(visualFocus: bool, selected: bool, destructive: var): color {
            if (visualFocus || selected)
                return destructive ? root.colors.danger : (visualFocus ? root.colors.focusRing : root.colors.accent);
            return Qt.color("transparent");
        }
    }

    component BarButtonTokens: QtObject {
        readonly property int height: Math.round(22 * root.controlScale)
        readonly property int padding: root.spacing.small

        function background(active: bool, urgent: bool): color {
            if (active)
                return root.colors.accent;
            if (urgent)
                return root.colors.danger;
            return "transparent";
        }

        function foreground(active: bool, urgent: bool): color {
            if (active)
                return root.colors.accentForeground;
            if (urgent)
                return root.colors.dangerForeground;
            return root.colors.textPrimary;
        }
    }

    component ToggleSwitchTokens: QtObject {
        function trackColor(enabled: bool, checked: bool): color {
            if (!enabled)
                return root.colors.disabledSurface;
            if (checked)
                return root.colors.accent;
            return root.colors.surfaceVariant;
        }

        function knobColor(enabled: bool, checked: bool): color {
            if (!enabled)
                return root.colors.disabledText;
            if (checked)
                return root.colors.accentForeground;
            return root.colors.textSecondary;
        }

        function borderColor(visualFocus: bool): color {
            if (visualFocus)
                return root.colors.focusRing;
            return "transparent";
        }
    }

    component BarGroupTokens: QtObject {
        readonly property int height: Math.round(24 * root.controlScale)
        readonly property color background: root.resolvedColorMode === "light" ? root.colors.background : root.colors.surface
        readonly property int padding: Math.round(6 * root.spacingScale)
        readonly property real radius: Math.min(height / 2, 13 * root.shape.scale)
    }

    component BarTokens: QtObject {
        readonly property int height: Math.round(30 * root.controlScale)
        readonly property int inset: Math.round(2 * root.spacingScale)
        readonly property color background: "transparent"
        readonly property color borderColor: "transparent"
        readonly property int padding: Math.round(6 * root.spacingScale)
    }

    component SurfaceTokens: QtObject {
        readonly property color fill: root.colors.surface
        readonly property real fillOpacity: root.definition.surface.fillOpacity
        readonly property string mode: root.definition.surface.mode
        readonly property real blurRadius: root.definition.surface.blurRadius
        readonly property int borderWidth: root.definition.border.width
        readonly property color borderColor: root.borderColor
        readonly property bool shadowEnabled: root.definition.elevation.shadowStyle !== "none"
        readonly property real shadowBlur: root.definition.elevation.shadowBlur
        readonly property real shadowHorizontalOffset: root.definition.elevation.shadowHorizontalOffset
        readonly property real shadowVerticalOffset: root.definition.elevation.shadowVerticalOffset
        readonly property color shadowColor: root.shadowColor
        readonly property bool highlightEnabled: root.definition.elevation.highlightStyle !== "none"
        readonly property color highlightColor: root.highlightColor
        readonly property real gradientLighten: root.definition.surface.gradientLighten
        readonly property real gradientDarken: root.definition.surface.gradientDarken
    }

    component StatusTokens: QtObject {
        function tone(urgent: bool): color {
            return urgent ? root.colors.danger : root.colors.accent;
        }

        function foreground(urgent: bool): color {
            return urgent ? root.colors.dangerForeground : root.colors.accentForeground;
        }

        function text(urgent: bool): color {
            return urgent ? root.colors.danger : root.colors.textPrimary;
        }
    }

    component CalendarTokens: QtObject {
        function dayBackground(today: bool, hovered: bool): color {
            if (today)
                return root.colors.accent;
            if (hovered)
                return root.colors.hoveredSurface;
            return Qt.color("transparent");
        }

        function dayForeground(today: bool): color {
            if (today)
                return root.colors.accentForeground;
            return root.colors.textPrimary;
        }
    }

    component ThemeCardTokens: QtObject {
        function background(checked: bool): color {
            return checked ? root.colors.selectedSurface : Qt.color("transparent");
        }

        function borderColor(checked: bool, visualFocus: bool): color {
            return (checked || visualFocus) ? root.colors.accent : root.colors.outline;
        }

        function accentColor(checked: bool): color {
            return checked ? root.colors.accent : root.colors.textSecondary;
        }
    }

    component ColorModeToggleTokens: QtObject {
        function trackColor(checked: bool): color {
            return checked ? Qt.rgba(root.colors.accent.r, root.colors.accent.g, root.colors.accent.b, 0.2) : root.colors.surfaceVariant;
        }

        function trackBorder(checked: bool): color {
            return checked ? root.colors.accent : root.colors.outline;
        }

        function knobColor(checked: bool): color {
            return checked ? root.colors.accent : root.colors.background;
        }

        function knobBorder(checked: bool): color {
            return checked ? root.colors.accent : root.colors.outline;
        }

        function knobForeground(checked: bool): color {
            return checked ? root.colors.accentForeground : root.colors.accent;
        }

        function iconColor(active: bool): color {
            return active ? root.colors.accent : root.colors.textSecondary;
        }
    }

    component NotificationTokens: QtObject {
        function indicatorTone(dnd: bool, unread: bool): color {
            if (dnd)
                return root.colors.danger;
            if (unread)
                return root.colors.accent;
            return root.colors.textPrimary;
        }

        function urgencyColor(urgency: int): color {
            return urgency === 2 ? root.colors.danger : root.colors.accent;
        }
    }

    component ComponentTokens: QtObject {
        readonly property SurfaceTokens surface: SurfaceTokens {}
        readonly property BarTokens bar: BarTokens {}
        readonly property BarGroupTokens barGroup: BarGroupTokens {}
        readonly property BarButtonTokens barButton: BarButtonTokens {}
        readonly property ActionButtonTokens actionButton: ActionButtonTokens {}
        readonly property ActionRowTokens actionRow: ActionRowTokens {}
        readonly property ToggleSwitchTokens toggleSwitch: ToggleSwitchTokens {}
        readonly property IconButtonTokens iconButton: IconButtonTokens {}
        readonly property PopupTokens popup: PopupTokens {}
        readonly property SliderTokens slider: SliderTokens {}
        readonly property StatusTokens status: StatusTokens {}
        readonly property CalendarTokens calendar: CalendarTokens {}
        readonly property ThemeCardTokens themeCard: ThemeCardTokens {}
        readonly property ColorModeToggleTokens colorModeToggle: ColorModeToggleTokens {}
        readonly property NotificationTokens notification: NotificationTokens {}
    }

    component ShapeTokens: QtObject {
        readonly property real scale: Math.max(0, Math.min(3, AppearanceSettings.radiusScale))
        readonly property real smallRadius: root.definition.shape.smallRadius * scale
        readonly property real controlRadius: root.definition.shape.controlRadius * scale
        readonly property real panelRadius: root.definition.shape.panelRadius * scale
        readonly property real roundRadius: root.definition.shape.roundRadius * scale
        readonly property int borderWidth: 1
    }

    component SpacingTokens: QtObject {
        readonly property real density: root.definition.spacing.density
        readonly property int tiny: Math.round(root.definition.spacing.tiny * density * root.spacingScale)
        readonly property int small: Math.round(root.definition.spacing.small * density * root.spacingScale)
        readonly property int medium: Math.round(root.definition.spacing.medium * density * root.spacingScale)
        readonly property int large: Math.round(root.definition.spacing.large * density * root.spacingScale)
        readonly property int extraLarge: Math.round(root.definition.spacing.extraLarge * density * root.spacingScale)
        readonly property int section: Math.round(root.definition.spacing.section * density * root.spacingScale)
    }

    component TypographyTokens: QtObject {
        readonly property string family: root.definition.typography.family || AppearanceSettings.fontFamily
        readonly property string iconFamily: AppearanceSettings.iconFontFamily
        readonly property int bodyWeight: root.definition.typography.bodyWeight
        readonly property int titleWeight: root.definition.typography.titleWeight
        readonly property real letterSpacing: root.definition.typography.letterSpacing
        readonly property int smallSize: Math.round(10 * root.fontScale)
        readonly property int captionSize: Math.round(11 * root.fontScale)
        readonly property int bodySize: Math.round(12 * root.fontScale)
        readonly property int titleSize: Math.round(15 * root.fontScale)
        readonly property int headingSize: Math.round(20 * root.fontScale)
        readonly property font body: Qt.font({
            family: family,
            pixelSize: bodySize,
            weight: bodyWeight,
            letterSpacing: letterSpacing
        })
        readonly property font caption: Qt.font({
            family: family,
            pixelSize: captionSize
        })
        readonly property font title: Qt.font({
            family: family,
            pixelSize: titleSize,
            weight: titleWeight,
            letterSpacing: letterSpacing
        })
    }

    component ColorTokens: QtObject {
        readonly property color background: root.paletteVariant.background
        readonly property color surface: root.paletteVariant.surface
        readonly property color surfaceVariant: root.paletteVariant.surfaceVariant
        readonly property color outline: root.paletteVariant.outline
        readonly property color textPrimary: root.paletteVariant.textPrimary
        readonly property color textSecondary: root.paletteVariant.textSecondary
        readonly property color danger: root.paletteVariant.danger
        readonly property color warning: root.paletteVariant.warning
        readonly property color success: root.paletteVariant.success
        readonly property color info: root.paletteVariant.info
        readonly property color accent: root.paletteVariant.accents[root.accentId]
        readonly property color accentForeground: ColorMath.foreground(accent.r, accent.g, accent.b)
        readonly property color dangerForeground: ColorMath.foreground(danger.r, danger.g, danger.b)
        readonly property color disabledText: ColorMath.alpha(textSecondary, 0.45)
        readonly property color disabledSurface: ColorMath.alpha(surfaceVariant, 0.5)
        readonly property color focusRing: ColorMath.alpha(accent, 0.5)
        readonly property color hoveredSurface: ColorMath.blend(surface, textPrimary, 0.08)
        readonly property color selectedSurface: ColorMath.blend(surface, accent, 0.16)
        readonly property color accentContainer: ColorMath.alpha(accent, 0.15)
        readonly property color dangerContainer: ColorMath.alpha(danger, 0.15)
        readonly property color scrim: Qt.rgba(0, 0, 0, root.resolvedColorMode === "dark" ? 0.45 : 0.25)
    }

    readonly property color borderColor: {
        const policy = root.definition.border.colorPolicy;
        const source = policy === "surfaceVariant" ? root.colors.surfaceVariant : root.colors.outline;
        if (policy === "transparent")
            return Qt.rgba(0, 0, 0, 0);
        return Qt.rgba(source.r, source.g, source.b, root.definition.border.opacity);
    }

    readonly property color shadowColor: {
        const policy = root.definition.elevation.shadowColorPolicy;
        const source = policy === "foreground" ? root.colors.textPrimary : Qt.rgba(0, 0, 0, 1);
        return Qt.rgba(source.r, source.g, source.b, root.definition.elevation.shadowOpacity);
    }

    readonly property color highlightColor: Qt.rgba(1, 1, 1, root.definition.elevation.highlightOpacity)
}
