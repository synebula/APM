pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts

import "../../services"
import "../../theme"
import "../../ui/controls"
import "./AudioPresentation.js" as AudioPresentation

Column {
    id: root

    required property string title
    required property var node
    property var devices: []
    signal deviceSelected(var device)
    spacing: Theme.spacing.medium

    SectionHeader {
        width: parent.width
        title: root.title
        subtitle: AudioService.nodeDisplayName(root.node) || "无可用设备"
        IconButton {
            enabled: root.node !== null
            glyph: AudioService.nodeMuted(root.node) ? "󰝟" : AudioPresentation.deviceGlyph(root.node)
            destructive: AudioService.nodeMuted(root.node)
            tooltipText: AudioService.nodeMuted(root.node) ? "取消静音" : "静音"
            onClicked: AudioService.toggleNodeMute(root.node)
        }
        TextLabel {
            text: AudioService.nodeMuted(root.node) ? "静音" : Math.round(AudioService.nodeVolume(root.node) * 100) + "%"
            color: Theme.components.status.tone(AudioService.nodeMuted(root.node))
        }
    }

    ValueSlider {
        width: parent.width
        enabled: root.node !== null
        value: AudioService.nodeVolume(root.node)
        progressColor: Theme.components.status.tone(AudioService.nodeMuted(root.node))
        onMoved: AudioService.setNodeVolume(root.node, value)
    }

    Repeater {
        model: root.devices
        delegate: ActionRow {
            required property var modelData
            width: root.width
            text: AudioService.nodeDisplayName(modelData)
            glyph: AudioPresentation.deviceGlyph(modelData)
            selected: root.node !== null && root.node.id === modelData.id
            trailingText: selected ? "✓" : ""
            onClicked: root.deviceSelected(modelData)
        }
    }
}
