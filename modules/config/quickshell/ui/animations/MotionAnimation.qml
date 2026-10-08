import QtQuick
import "../../theme"
import "../../theme/motion"

NumberAnimation {
    id: root

    property MotionSpec motion: Theme.motion.standard
    property real durationMultiplier: 1

    duration: Math.round(root.motion.duration * root.durationMultiplier)
    easing.type: root.motion.easing
    // Setting non-empty control points makes Qt select BezierSpline, even if
    // easing.type was set to a built-in curve such as OutBounce.
    easing.bezierCurve: root.motion.easing === Easing.BezierSpline ? root.motion.curve : []
}
