import QtQuick

QtObject {
    property int duration: 150
    property int easing: Easing.BezierSpline
    property list<real> curve: [0.2, 0, 0, 1, 1, 1]
}
