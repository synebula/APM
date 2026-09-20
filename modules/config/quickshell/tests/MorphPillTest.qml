import "../ui/containers"
import "../ui/effects"
import QtQuick

TestSuite {
    id: root

    name: "MorphPill"

    function test_pillMorphSurfaceDefaults() {
        verify(surface !== null);
        compare(surface.edgeSoftness, 0.8);
    }

    function test_morphPillExpandsAndCollapses() {
        compare(pill.expanded, false);
        compare(pill.testProgress, -1);
        pill.expanded = true;
        compare(pill.expanded, true);
        pill.testProgress = 1.0;
        verify(pill.visualWidth > pill.baseWidth);
        compare(pill.satelliteAlpha, 1.0);
        compare(pill.currentBlendRadius, 0);
        pill.expanded = false;
        pill.testProgress = 0.0;
        compare(pill.pillProgress, 0);
        compare(pill.satelliteAlpha, 0);
    }

    function test_morphPillInterpolations() {
        pill.testProgress = 0.55;
        // 在 0.55 进度时应该处于拉伸粘连阶段 (blendRadius > 0)
        verify(pill.currentBlendRadius > 0);
        verify(pill.currentMainWidth > pill.baseWidth);
        pill.testProgress = -1;
    }

    PillMorphSurface {
        id: surface

        width: 200
        height: 50
        mainCenter: Qt.vector2d(100, 25)
        mainSize: Qt.vector2d(180, 40)
        mainRadius: 20
        satelliteCenter: Qt.vector2d(100, 25)
        satelliteSize: Qt.vector2d(40, 40)
        satelliteRadius: 20
        blendRadius: 0
    }

    MorphPill {
        id: pill

        baseWidth: 200
        baseHeight: 40
    }
}
