pragma Singleton
import QtQuick
import Quickshell
import ".."
import "../presets"

Singleton {
    id: root

    readonly property list<MotionProfile> profiles: [
        StandardMotion {},
        SnappyMotion {},
        GentleMotion {}
    ]

    function find(motionId: string): MotionProfile {
        return root.profiles.find(profile => profile.motionId === motionId) || null;
    }
}
