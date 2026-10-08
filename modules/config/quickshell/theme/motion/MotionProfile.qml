import QtQuick

QtObject {
    id: root

    property string motionId: ""
    property string displayName: "自定义"
    property string description: ""
    property int duration: 150
    property MotionSpec fastEffects: MotionSpec { duration: root.duration }
    property MotionSpec standard: MotionSpec { duration: root.duration }
    property MotionSpec slowEffects: MotionSpec { duration: root.duration }
    property MotionSpec spatial: MotionSpec { duration: root.duration }
    property MotionSpec accelerate: MotionSpec { duration: root.duration }
    property MotionSpec scroll: MotionSpec { duration: root.duration }
    property MotionSpec bounce: MotionSpec { duration: root.duration; easing: Easing.OutBounce }
    property MotionSpec linear: MotionSpec { duration: root.duration; easing: Easing.Linear }
    property MotionSpec symmetric: MotionSpec { duration: root.duration; easing: Easing.InOutQuad }
    property MotionSpec feedback: MotionSpec { duration: root.duration; easing: Easing.InOutQuad }
}
