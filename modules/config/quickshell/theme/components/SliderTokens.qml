import QtQuick

QtObject {
    id: root

    required property real controlScale
    required property real spacingScale

    readonly property int height: Math.round(20 * root.controlScale)
    readonly property int trackHeight: Math.round(6 * root.spacingScale)
    readonly property int handleSize: Math.round(14 * root.controlScale)

    function handleBorderWidth(visualFocus: bool): int {
        return visualFocus ? 3 : 2;
    }
}
