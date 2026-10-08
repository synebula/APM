import QtQuick

StandardMotion {
    motionId: "gentle"
    displayName: "柔和"
    description: "平缓启停，舒展过渡"
    duration: 340

    fastEffects.curve: [0.25, 0.1, 0.25, 1, 1, 1]
    standard.curve: [0.4, 0, 0.2, 1, 1, 1]
    slowEffects.curve: [0.4, 0, 0.2, 1, 1, 1]
    spatial.curve: [0.4, 0, 0.2, 1, 1, 1]
    spatial.duration: duration * 1.5
    accelerate.curve: [0.4, 0, 0.7, 0.4, 1, 1]
    accelerate.duration: duration
    scroll.curve: [0.25, 0.1, 0.25, 1, 1, 1]
}
