import "../../theme"
import QtQuick
import Quickshell

Item {
    id: root

    property string source: ""
    property string fallbackGlyph: "󰈙"
    property color foreground: Theme.colors.textPrimary
    readonly property string resolvedSource: {
        if (!root.source)
            return "";

        if (root.source.startsWith("/"))
            return "file://" + root.source;

        if (root.source.startsWith("image://icon/")) {
            const sub = root.source.slice(13);
            if (sub.startsWith("/"))
                return "file://" + sub;
            return Quickshell.iconPath(sub, true);
        }

        if (root.source.includes("://"))
            return root.source;

        return Quickshell.iconPath(root.source, true);
    }

    implicitWidth: Theme.components.iconButton.size
    implicitHeight: implicitWidth

    Image {
        id: image

        anchors.fill: parent
        source: root.resolvedSource
        sourceSize.width: root.width
        sourceSize.height: root.height
        fillMode: Image.PreserveAspectFit
        visible: root.resolvedSource.length > 0 && status === Image.Ready
    }

    IconGlyph {
        anchors.centerIn: parent
        visible: !image.visible
        text: root.fallbackGlyph
        color: root.foreground
    }
}
