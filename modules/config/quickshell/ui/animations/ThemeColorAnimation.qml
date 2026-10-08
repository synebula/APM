import QtQuick
import "../../theme"
import "../../theme/motion"

ColorAnimation {
    id: root

    property MotionSpec motion: Theme.motion.linear

    duration: root.motion.duration
    easing.type: root.motion.easing
    easing.bezierCurve: root.motion.easing === Easing.BezierSpline ? root.motion.curve : []
}
