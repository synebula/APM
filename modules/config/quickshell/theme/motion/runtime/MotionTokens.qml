import QtQuick
import ".."

QtObject {
    id: root

    required property MotionProfile spec
    property real scale: 1

    readonly property MotionSpec fastEffects: MotionSpec {
        duration: Math.round(root.spec.fastEffects.duration * root.scale)
        easing: root.spec.fastEffects.easing
        curve: root.spec.fastEffects.curve
    }

    readonly property MotionSpec standard: MotionSpec {
        duration: Math.round(root.spec.standard.duration * root.scale)
        easing: root.spec.standard.easing
        curve: root.spec.standard.curve
    }

    readonly property MotionSpec slowEffects: MotionSpec {
        duration: Math.round(root.spec.slowEffects.duration * root.scale)
        easing: root.spec.slowEffects.easing
        curve: root.spec.slowEffects.curve
    }

    readonly property MotionSpec spatial: MotionSpec {
        duration: Math.round(root.spec.spatial.duration * root.scale)
        easing: root.spec.spatial.easing
        curve: root.spec.spatial.curve
    }

    readonly property MotionSpec accelerate: MotionSpec {
        duration: Math.round(root.spec.accelerate.duration * root.scale)
        easing: root.spec.accelerate.easing
        curve: root.spec.accelerate.curve
    }

    readonly property MotionSpec scroll: MotionSpec {
        duration: Math.round(root.spec.scroll.duration * root.scale)
        easing: root.spec.scroll.easing
        curve: root.spec.scroll.curve
    }
}
