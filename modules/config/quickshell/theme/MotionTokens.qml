import QtQuick

QtObject {
    id: root

    property real scale: 1
    property int baseDuration: 200
    readonly property MotionSpec fastEffects: MotionSpec {
        duration: Math.round(root.baseDuration * 0.75 * root.scale)
        curve: [0.31, 0.94, 0.34, 1, 1, 1]
    }

    readonly property MotionSpec standard: MotionSpec {
        duration: Math.round(root.baseDuration * root.scale)
    }

    readonly property MotionSpec slowEffects: MotionSpec {
        duration: Math.round(root.baseDuration * 1.5 * root.scale)
        curve: [0.34, 0.88, 0.34, 1, 1, 1]
    }

    readonly property MotionSpec spatial: MotionSpec {
        duration: Math.round(root.baseDuration * 1.75 * root.scale)
        curve: [0.42, 1.67, 0.21, 0.9, 1, 1]
    }

    readonly property MotionSpec scroll: MotionSpec {
        duration: Math.round(root.baseDuration * root.scale)
        curve: [0, 0, 0, 1, 1, 1]
    }
}
