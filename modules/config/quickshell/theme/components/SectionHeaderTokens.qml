import QtQuick

QtObject {
    id: root

    required property real controlScale

    readonly property int iconContainerSize: Math.round(32 * root.controlScale)
}
