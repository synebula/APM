import QtQuick

QtObject {
    property string level: "flat"
    property string shadowStyle: "none"
    property real shadowBlur: 0
    property real shadowHorizontalOffset: 0
    property real shadowVerticalOffset: 0
    property real shadowOpacity: 0
    property string shadowColorPolicy: "black"
    property string darkShadowColorPolicy: "black"
    property real darkShadowOpacity: shadowOpacity
    property string highlightStyle: "none"
    property real highlightOpacity: 0
    property real darkHighlightOpacity: highlightOpacity
}
