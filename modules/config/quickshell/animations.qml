import QtQuick
import QtQuick.Window
import QtQuick.Layouts
import Quickshell
import "theme"
import "ui/animations"
import "ui/containers"
import "ui/controls"

ShellRoot {
    Window {
        id: window

        readonly property real playbackScale: slowButton.checked ? 3 : 1

        title: "QuickShell · 动效工坊"
        visible: true
        width: 880
        height: 800
        minimumWidth: 400
        minimumHeight: 480
        color: Theme.colors.background

        Flickable {
            anchors.fill: parent
            contentWidth: width
            contentHeight: content.implicitHeight + Theme.spacing.section * 2
            boundsBehavior: Flickable.StopAtBounds
            clip: true

            ColumnLayout {
                id: content

                x: Theme.spacing.section
                y: Theme.spacing.section
                width: parent.width - Theme.spacing.section * 2
                spacing: Theme.spacing.extraLarge

                TextLabel {
                    text: "QUICKSHELL  /  MOTION"
                    font: Theme.typography.caption
                    color: Theme.colors.accent
                }

                TextLabel {
                    text: "动效工坊"
                    font: Theme.typography.heading
                }

                TextLabel {
                    text: "四种基础动效，自由组合。点击卡片重播，也可用 Tab 和空格操作。"
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                    color: Theme.colors.textSecondary
                }

                RowLayout {
                    spacing: Theme.spacing.medium

                    ActionButton {
                        objectName: "replayAll"
                        text: "全部重播"
                        primary: true
                        onClicked: {
                            fade.animation.restart();
                            slide.animation.restart();
                            scale.animation.restart();
                            bounce.animation.restart();
                        }
                    }

                    ActionButton {
                        id: slowButton
                        objectName: "slowPlayback"
                        text: "慢速观察"
                        checkable: true
                    }
                }

                TextLabel {
                    visible: Theme.motion.scale === 0
                    text: "当前主题已关闭动画，重播会直接显示结束状态。"
                    color: Theme.colors.textSecondary
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }

                GridLayout {
                    columns: content.width >= 640 * Theme.controlScale ? 2 : 1
                    columnSpacing: Theme.spacing.extraLarge
                    rowSpacing: Theme.spacing.extraLarge
                    Layout.fillWidth: true

                    MotionSample {
                        id: fade
                        objectName: "fadeSample"
                        number: "01"
                        heading: "淡入淡出"
                        description: "透明度渐变，让内容自然出现。"
                        animation: FadeAnimation {
                            target: fade.tile
                            from: 0
                            to: 1
                            durationMultiplier: window.playbackScale
                        }
                    }

                    MotionSample {
                        id: slide
                        objectName: "slideSample"
                        number: "02"
                        heading: "滑动"
                        description: "平滑入场，保留清晰的方向感。"
                        animation: SlideAnimation {
                            target: slide.offset
                            property: "x"
                            from: -Theme.spacing.section * 3
                            to: 0
                            durationMultiplier: window.playbackScale
                        }
                    }

                    MotionSample {
                        id: scale
                        objectName: "scaleSample"
                        number: "03"
                        heading: "缩放"
                        description: "从中心展开，聚焦当前内容。"
                        animation: ScaleAnimation {
                            target: scale.tile
                            from: 0.65
                            to: 1
                            durationMultiplier: window.playbackScale
                        }
                    }

                    MotionSample {
                        id: bounce
                        objectName: "bounceSample"
                        number: "04"
                        heading: "弹跳"
                        description: "落下后轻轻回弹，逐步停稳。"
                        animation: BounceAnimation {
                            target: bounce.offset
                            from: -Theme.spacing.section * 2
                            to: 0
                            durationMultiplier: window.playbackScale
                        }
                    }
                }

                TextLabel {
                    text: "动效：" + Theme.motionProfile.displayName
                        + (Theme.motionFollowsTheme ? "（跟随主题）" : "")
                        + " · 慢速观察仅影响本页"
                    font: Theme.typography.caption
                    color: Theme.colors.textSecondary
                    wrapMode: Text.Wrap
                    Layout.fillWidth: true
                }
            }
        }
    }

    component MotionSample: InteractiveCard {
        id: sample

        required property string number
        required property string heading
        required property string description
        required property Animation animation
        property alias tile: tile
        property alias offset: offset

        Layout.fillWidth: true
        Layout.preferredWidth: 1
        padding: Theme.spacing.extraLarge
        onClicked: animation.restart()

        contentItem: ColumnLayout {
            spacing: Theme.spacing.medium

            RowLayout {
                TextLabel {
                    text: sample.number
                    font: Theme.typography.caption
                    color: Theme.colors.accent
                }
                TextLabel {
                    text: sample.heading
                    font: Theme.typography.title
                    Layout.fillWidth: true
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.spacing.section * 7

                Rectangle {
                    id: tile
                    anchors.centerIn: parent
                    width: Theme.spacing.section * 3
                    height: width
                    radius: Theme.shape.controlRadius
                    color: Theme.colors.accent
                    transform: Translate { id: offset }

                    TextLabel {
                        anchors.centerIn: parent
                        text: sample.number
                        font: Theme.typography.heading
                        color: Theme.colors.accentForeground
                    }
                }
            }

            TextLabel {
                text: sample.description
                color: Theme.colors.textSecondary
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            TextLabel {
                text: sample.animation.running ? "播放中…" : "点击重播 ↗"
                color: Theme.colors.accent
                font: Theme.typography.caption
            }
        }
    }
}
