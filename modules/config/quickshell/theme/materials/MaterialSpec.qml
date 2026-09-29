import QtQuick

QtObject {
    property Surface surface: Surface {}
    property Border border: Border {}
    property Elevation elevation: Elevation {}

    component Surface: QtObject {
        property string mode: "solid"
        property real fillOpacity: 1
        property real blurRadius: 0
        property real gradientLighten: 1
        property real gradientDarken: 1
        property real fresnelStrength: 0
        property real specularOpacity: 0
        property real textHaloOpacity: 0
    }

    component Border: QtObject {
        property int width: 1
        property real opacity: 1
        property string colorPolicy: "outline"
    }

    component Elevation: QtObject {
        property bool shadowEnabled: false
        property real shadowBlur: 0
        property real shadowHorizontalOffset: 0
        property real shadowVerticalOffset: 0
        property real shadowOpacity: 0
        property string shadowColorPolicy: "black"
        property string darkShadowColorPolicy: "black"
        property real darkShadowOpacity: shadowOpacity
        property bool highlightEnabled: false
        property real highlightOpacity: 0
        property real darkHighlightOpacity: highlightOpacity
    }
}
