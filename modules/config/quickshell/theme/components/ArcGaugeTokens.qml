import QtQuick

QtObject {
    id: root

    required property real controlScale
    required property real fontScale

    readonly property int size: Math.round(22 * root.controlScale)
    readonly property real glyphSize: 9 * root.fontScale
    readonly property real arcRadius: 8.5 * root.controlScale
    readonly property real lineWidth: 2.2 * root.controlScale
    readonly property real handleSpacing: 3 * root.controlScale
    readonly property real handleInner: 1.2 * root.controlScale
    readonly property real handleOuter: 2.2 * root.controlScale
}
