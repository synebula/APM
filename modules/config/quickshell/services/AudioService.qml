pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property bool ready: Pipewire.ready
    readonly property var defaultOutput: Pipewire.defaultAudioSink
    readonly property var defaultInput: Pipewire.defaultAudioSource
    readonly property var audioNodes: Pipewire.nodes.values.filter(node => {
        return node && node.audio;
    })
    readonly property var outputDevices: root.sortedNodes(root.audioNodes.filter(node => {
        return !node.isStream && node.isSink;
    }))
    readonly property var inputDevices: root.sortedNodes(root.audioNodes.filter(node => {
        return !node.isStream && !node.isSink;
    }))
    readonly property var playbackStreams: root.playbackNodes(playbackTracker.linkGroups)
    readonly property real outputVolume: root.nodeVolume(root.defaultOutput)
    readonly property bool outputMuted: root.nodeMuted(root.defaultOutput)
    readonly property string outputName: root.nodeDisplayName(root.defaultOutput)
    readonly property real inputVolume: root.nodeVolume(root.defaultInput)
    readonly property bool inputMuted: root.nodeMuted(root.defaultInput)
    readonly property string inputName: root.nodeDisplayName(root.defaultInput)

    function sortedNodes(nodes) {
        return nodes.slice().sort((a, b) => {
            return root.nodeDisplayName(a).localeCompare(root.nodeDisplayName(b));
        });
    }

    function playbackNodes(groups) {
        const streams = [];
        const seen = {};
        for (let i = 0; i < groups.length; i++) {
            const node = groups[i] ? groups[i].source : null;
            if (!node || !node.audio || !node.isStream)
                continue;

            const id = String(node.id);
            if (seen[id])
                continue;

            seen[id] = true;
            streams.push(node);
        }
        return root.sortedNodes(streams);
    }

    function nodeProperties(node) {
        return (node && node.properties) ? node.properties : {};
    }

    function nodeDisplayName(node) {
        if (!node)
            return "";

        const props = root.nodeProperties(node);
        return props["media.name"] || props["application.name"] || node.description || node.nickname || node.name || "Audio Device";
    }

    function nodeVolume(node) {
        return (node && node.audio) ? Math.max(0, Math.min(1, node.audio.volume)) : 0;
    }

    function nodeMuted(node) {
        return (node && node.audio) ? node.audio.muted : false;
    }

    function setNodeVolume(node, val) {
        if (node && node.audio && Number.isFinite(Number(val))) {
            node.audio.volume = Math.max(0, Math.min(1, Number(val)));
            if (node.audio.muted)
                node.audio.muted = false;
        }
    }

    function toggleNodeMute(node) {
        if (node && node.audio)
            node.audio.muted = !node.audio.muted;
    }

    function setOutputVolume(val) {
        root.setNodeVolume(root.defaultOutput, val);
    }

    function toggleOutputMute() {
        root.toggleNodeMute(root.defaultOutput);
    }

    function adjustOutputVolume(delta) {
        if (root.defaultOutput && root.defaultOutput.audio)
            root.setOutputVolume(root.outputVolume + delta);
    }

    function setInputVolume(val) {
        root.setNodeVolume(root.defaultInput, val);
    }

    function toggleInputMute() {
        root.toggleNodeMute(root.defaultInput);
    }

    function setDefaultOutput(node) {
        if (node)
            Pipewire.preferredDefaultAudioSink = node;
    }

    function setDefaultInput(node) {
        if (node)
            Pipewire.preferredDefaultAudioSource = node;
    }

    PwObjectTracker {
        objects: root.audioNodes
    }

    PwNodeLinkTracker {
        id: playbackTracker

        node: root.defaultOutput
    }
}
