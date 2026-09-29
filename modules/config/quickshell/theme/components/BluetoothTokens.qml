import QtQuick
import "../colors/runtime"

QtObject {
    id: root

    required property ColorTokens colors

    function actionColor(connected: bool): color {
        return connected ? root.colors.danger : root.colors.textSecondary;
    }
}
