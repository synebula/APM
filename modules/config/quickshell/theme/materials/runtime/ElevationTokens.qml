import QtQuick
import ".."

QtObject {
    id: root

    required property MaterialSpec.Elevation spec
    required property bool isDark

    readonly property string shadowColorPolicy: root.isDark ? root.spec.darkShadowColorPolicy : root.spec.shadowColorPolicy
    readonly property real shadowOpacity: root.isDark ? root.spec.darkShadowOpacity : root.spec.shadowOpacity
    readonly property real highlightOpacity: root.isDark ? root.spec.darkHighlightOpacity : root.spec.highlightOpacity
}
