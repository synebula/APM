import QtQuick
import ".."

QtObject {
    id: root

    required property TypographySpec spec
    required property string fontFamily
    required property string iconFamily
    required property real fontScale

    readonly property font small: scaledFont(root.spec.small)
    readonly property font caption: scaledFont(root.spec.caption)
    readonly property font body: scaledFont(root.spec.body)
    readonly property font title: scaledFont(root.spec.title)
    readonly property font heading: scaledFont(root.spec.heading)

    function scaledFont(style: font): font {
        return withOverrides(style, {
            family: style.family || root.spec.family || root.fontFamily,
            pixelSize: Math.round(style.pixelSize * root.fontScale)
        });
    }

    function withOverrides(style: font, overrides: var): font {
        // Copy through native setters; Qt.font(object) does not preserve every flag.
        const result = Qt.font({ pixelSize: style.pixelSize });
        for (const key of Object.keys(style)) {
            if (key !== "pointSize")
                result[key] = style[key];
        }
        for (const key of Object.keys(overrides))
            result[key] = overrides[key];
        return result;
    }
}
