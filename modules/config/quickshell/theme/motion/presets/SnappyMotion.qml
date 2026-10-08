import QtQuick

StandardMotion {
    motionId: "snappy"
    displayName: "轻快"
    description: "短促响应，快速停稳"
    duration: 140

    fastEffects.curve: [0.15, 0.85, 0.2, 1, 1, 1]
    standard.curve: [0.16, 1, 0.3, 1, 1, 1]
    slowEffects.duration: duration * 1.25
    spatial.curve: [0.2, 0.8, 0.2, 1, 1, 1]
    spatial.duration: duration * 1.25
    accelerate.curve: [0.4, 0, 1, 1, 1, 1]
    scroll.curve: [0.1, 0.8, 0.2, 1, 1, 1]
}
