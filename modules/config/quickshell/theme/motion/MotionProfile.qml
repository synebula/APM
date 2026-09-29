import QtQuick

QtObject {
    id: root

    property int duration: 150
    property MotionSpec fastEffects: MotionSpec { duration: root.duration }
    property MotionSpec standard: MotionSpec { duration: root.duration }
    property MotionSpec slowEffects: MotionSpec { duration: root.duration }
    property MotionSpec spatial: MotionSpec { duration: root.duration }
    property MotionSpec accelerate: MotionSpec { duration: root.duration }
    property MotionSpec scroll: MotionSpec { duration: root.duration }
}
