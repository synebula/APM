import QtQuick
import "../theme/themes"
import "../theme/colors/presets"
import "../theme/colors/runtime"
import "../theme/geometry/runtime"
import "../theme/materials"
import "../theme/materials/runtime"
import "../theme/motion/presets"
import "../theme/motion/runtime"
import "../theme/typography/runtime"

TestSuite {
    id: root
    name: "ThemeComposition"

    Component {
        id: fixtureComponent

        QtObject {
            id: fixture
            property FlatTheme flat: FlatTheme {}
            property FlatTheme otherFlat: FlatTheme {}
            property LiquidGlassTheme glass: LiquidGlassTheme {}
            property LiquidGlassTheme otherGlass: LiquidGlassTheme {}
            property MaterialSpec.Surface customSurface: MaterialSpec.Surface { fillOpacity: 0.6 }
            property MaterialSpec.Border customBorder: MaterialSpec.Border { width: 2; opacity: 0.4 }
            property bool dark: false
            property SurfaceTokens surface: SurfaceTokens {
                spec: fixture.flat.material
                colors: fixture.colors
                isDark: fixture.dark
                controlScale: 1
            }
            property StandardMotion profile: StandardMotion { duration: 150 }
            property MotionTokens motion: MotionTokens {
                spec: fixture.profile
                scale: 1.5
            }
            property ShapeTokens shape: ShapeTokens {
                spec: fixture.flat.geometry.shape
                radiusScale: 1.5
            }
            property SpacingTokens spacing: SpacingTokens {
                spec: fixture.flat.geometry.spacing
                spacingScale: 0.8
            }
            property TypographyTokens typography: TypographyTokens {
                spec: fixture.flat.typography
                fontFamily: "sans-serif"
                iconFamily: "monospace"
                fontScale: 1.5
            }
            property Nord nord: Nord {}
            property ColorTokens colors: ColorTokens {
                variant: fixture.flat.palette.variant("light")
                requestedAccentId: "missing"
                isDark: false
            }
        }
    }

    function fixture() {
        const object = createTemporaryObject(fixtureComponent, root);
        verify(object !== null, fixtureComponent.errorString());
        return object;
    }

    function test_localOverridesDoNotMutateSharedPresets() {
        const f = fixture();
        f.flat.material.border.opacity = 0.25;
        f.flat.geometry.shape.panelRadius = 7;
        compare(f.otherFlat.material.border.opacity, 1);
        compare(f.otherFlat.geometry.shape.panelRadius, 12);
        compare(f.glass.material.border.opacity, 0.9);
        compare(f.glass.geometry.shape.panelRadius, 24);
        compare(f.shape.panelRadius, 10.5);
    }

    function test_runtimeFollowsReplacementAndScale() {
        const f = fixture();
        f.shape.spec = f.glass.geometry.shape;
        compare(f.shape.panelRadius, 36);
        f.shape.radiusScale = 0;
        compare(f.shape.panelRadius, 0);
        f.spacing.spec = f.glass.geometry.spacing;
        compare(f.spacing.large, Math.round(12 * 1.06 * 0.8));
        f.glass.geometry.spacing.density = 1.2;
        compare(f.spacing.large, Math.round(12 * 1.2 * 0.8));
    }

    function test_motionRoundsAfterScalingAndUsesPresetCurve() {
        const f = fixture();
        compare(f.motion.fastEffects.duration, 169);
        f.profile.standard.duration = 123.4;
        f.profile.standard.easing = Easing.Linear;
        f.profile.standard.curve = [0.4, 0, 1, 1, 1, 1];
        compare(f.motion.standard.duration, 185);
        compare(f.motion.standard.easing, Easing.Linear);
        compare(JSON.stringify(f.motion.standard.curve), JSON.stringify(f.profile.standard.curve));
        f.motion.scale = 0;
        for (const role of ["fastEffects", "standard", "slowEffects", "spatial", "accelerate", "scroll", "bounce", "linear", "symmetric", "feedback"])
            compare(f.motion[role].duration, 0);
    }

    function test_typographyUsesPresetSizesAndUserFont() {
        const f = fixture();
        compare(f.typography.body.pixelSize, 18);
        compare(f.typography.body.family, "sans-serif");
        f.flat.typography.body.pixelSize = 14;
        f.flat.typography.family = "monospace";
        compare(f.typography.body.pixelSize, 21);
        compare(f.typography.body.family, "monospace");
        compare(f.otherFlat.typography.body.pixelSize, 12);
    }

    function test_materialPresetCanBeMixedAndReplaced() {
        const f = fixture();
        const palette = f.flat.palette;
        f.flat.material = f.glass.material;
        compare(f.surface.mode, "liquid");
        compare(f.surface.fillOpacity, 0.1);
        verify(f.surface.shadowEnabled);
        compare(f.surface.shadowBlur, 0.9);
        compare(f.flat.palette, palette);
        compare(f.shape.panelRadius, 18);
        compare(f.flat.typography.title.weight, Font.Bold);

        f.flat.material.surface = f.customSurface;
        compare(f.surface.fillOpacity, 0.6);
        compare(f.surface.mode, "solid");
        compare(f.surface.shadowBlur, 0.9);
        f.flat.material.border = f.customBorder;
        compare(f.surface.borderWidth, 2);
        compare(f.surface.borderColor.a, Qt.rgba(0, 0, 0, 0.4).a);
        f.flat.material.elevation.darkShadowOpacity = 0.7;
        f.dark = true;
        compare(f.surface.shadowColor.a, Qt.rgba(0, 0, 0, 0.7).a);
    }

    function test_presetInstancesOwnTheirNestedObjects() {
        const f = fixture();
        f.glass.material.border.opacity = 0.2;
        f.glass.material.surface.fillOpacity = 0.8;
        f.glass.material.elevation.shadowBlur = 0.3;
        f.glass.geometry.spacing.density = 2;
        f.glass.typography.title.weight = Font.Light;
        compare(f.otherGlass.material.border.opacity, 0.9);
        compare(f.otherGlass.material.surface.fillOpacity, 0.1);
        compare(f.otherGlass.material.elevation.shadowBlur, 0.9);
        compare(f.otherGlass.geometry.spacing.density, 1.06);
        compare(f.otherGlass.typography.title.weight, Font.DemiBold);
    }

    function test_geometryPresetReplacesShapeAndSpacingTogether() {
        const f = fixture();
        f.flat.geometry = f.glass.geometry;
        compare(f.shape.panelRadius, 36);
        compare(f.spacing.large, Math.round(12 * 1.06 * 0.8));
        f.flat.geometry.shape.panelRadius = 10;
        f.flat.geometry.spacing.density = 1.2;
        compare(f.shape.panelRadius, 15);
        compare(f.spacing.large, Math.round(12 * 1.2 * 0.8));
        compare(f.otherFlat.geometry.shape.panelRadius, 12);
    }

    function test_fontRolesPreserveStylesAndResolveFamiliesIndependently() {
        const f = fixture();
        f.flat.typography.family = "serif";
        f.flat.typography.title.family = "monospace";
        f.flat.typography.title.pixelSize = 17;
        f.flat.typography.title.italic = true;
        f.flat.typography.title.wordSpacing = 2;
        compare(f.typography.body.family, "serif");
        compare(f.typography.title.family, "monospace");
        compare(f.typography.title.pixelSize, 26);
        verify(f.typography.title.italic);
        compare(f.typography.title.wordSpacing, 2);
        compare(f.typography.title.preferTypoLineMetrics, false);
        f.flat.typography.title.preferTypoLineMetrics = true;
        verify(f.typography.title.preferTypoLineMetrics);
        compare(f.flat.typography.title.pixelSize, 17);
        compare(f.typography.body.pixelSize, 18);
        verify(!f.typography.body.italic);
        f.flat.typography.family = "";
        f.typography.fontFamily = "sans-serif";
        compare(f.typography.body.family, "sans-serif");
        compare(f.typography.title.family, "monospace");
        compare(f.otherFlat.typography.title.pixelSize, 15);
    }

    function test_fontPresetOverridesKeepBaseSizesAndUserFamily() {
        const f = fixture();
        f.typography.spec = f.glass.typography;
        compare(f.typography.body.pixelSize, 18);
        compare(f.typography.title.pixelSize, 23);
        compare(f.typography.body.family, "sans-serif");
        compare(f.typography.title.family, "sans-serif");
        compare(f.typography.title.weight, Font.DemiBold);
        compare(f.typography.body.letterSpacing, f.glass.typography.body.letterSpacing);
        f.glass.typography.title.pixelSize = 17;
        compare(f.typography.title.pixelSize, 26);
        compare(f.typography.title.weight, Font.DemiBold);
    }

    function test_paletteReplacementResolvesAccentLocally() {
        const f = fixture();
        compare(f.colors.accentId, f.flat.palette.variant("light").defaultAccentId);
        f.colors.requestedAccentId = "green";
        compare(f.colors.accent.toString(), f.colors.variant.accents.green.toString());
        f.colors.variant = f.nord.variant("dark");
        f.colors.isDark = true;
        compare(f.colors.background.toString(), f.nord.variant("dark").background.toString());
        f.colors.requestedAccentId = "missing";
        compare(f.colors.accentId, f.nord.variant("dark").defaultAccentId);
        compare(f.colors.accent.toString(), f.colors.variant.accents[f.colors.accentId].toString());
    }
}
