import QtQuick

QtObject {
    id: root

    required property real controlScale
    required property real spacingScale

    readonly property int height: Math.round(30 * root.controlScale)
    readonly property int inset: Math.round(2 * root.spacingScale)
    readonly property color background: "transparent"
    readonly property color borderColor: "transparent"
    readonly property int padding: Math.round(6 * root.spacingScale)
}
