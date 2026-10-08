import QtQuick
import ".."

MotionProfile {
    id: root

    motionId: "standard"
    displayName: "标准"
    description: "自然入场，利落退场"
    duration: 220
    fastEffects: MotionSpec {
        duration: root.duration * 0.75
        curve: [0.31, 0.94, 0.34, 1, 1, 1]
    }
    standard: MotionSpec {
        duration: root.duration
        curve: [0.2, 0, 0, 1, 1, 1]
    }
    slowEffects: MotionSpec {
        duration: root.duration * 1.5
        curve: [0.34, 0.88, 0.34, 1, 1, 1]
    }
    spatial: MotionSpec {
        duration: root.duration * 1.75
        curve: [0.42, 1.67, 0.21, 0.9, 1, 1]
    }
    accelerate: MotionSpec {
        duration: root.duration * 0.75
        curve: [0.3, 0, 0.8, 0.15, 1, 1]
    }
    scroll: MotionSpec {
        duration: root.duration
        curve: [0, 0, 0, 1, 1, 1]
    }
    bounce: MotionSpec {
        duration: root.duration * 1.75
        easing: Easing.OutBounce
    }
    linear: MotionSpec {
        duration: root.duration
        easing: Easing.Linear
    }
    symmetric: MotionSpec {
        duration: root.duration * 1.5
        easing: Easing.InOutQuad
    }
    feedback: MotionSpec {
        duration: root.duration * 0.2
        easing: Easing.InOutQuad
    }
}
