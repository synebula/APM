import QtQuick

QtObject {
    property Shape shape: Shape {}
    property Spacing spacing: Spacing {}

    component Shape: QtObject {
        property real smallRadius: 4
        property real controlRadius: 8
        property real panelRadius: 12
        property real roundRadius: 26
    }

    component Spacing: QtObject {
        property real density: 1
        property real tiny: 2
        property real small: 4
        property real medium: 8
        property real large: 12
        property real extraLarge: 16
        property real section: 20
    }
}
