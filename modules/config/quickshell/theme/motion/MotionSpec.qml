import QtQuick

QtObject {
    // Preserve fractional preset durations; runtime rounds after applying the user scale.
    property real duration: 150
    property int easing: Easing.BezierSpline
    property list<real> curve: [0.2, 0, 0, 1, 1, 1]
}
