import QtQuick

QtObject {
    id: root

    required property real controlScale
    required property real fontScale

    readonly property int size: Math.round(28 * root.controlScale)
    readonly property int compactSize: Math.round(22 * root.controlScale)
    readonly property int iconSize: Math.round(14 * root.fontScale)
}
