# 常用动画

生产界面与演示共用一条动效链：`theme/motion/presets/` 定义方案、角色时长和曲线，主题中心选择并保存方案，`MotionTokens` 应用用户倍率，`ui/animations` 负责绑定具体目标并执行 Qt 动画。

主题中心的“动效方案”提供“跟随主题 / 标准 / 轻快 / 柔和”。显式方案独立于配色和完整主题，重置为跟随主题会采用主题的默认动效；切换方案保持当前时长倍率。IPC 可用 `qs ipc call theme setMotion gentle`、`qs ipc call theme resetMotion`。

`MotionAnimation` 统一数值动画；淡入、滑动、缩放、弹跳都继承它。`ThemeColorAnimation` 统一颜色动画。沿用原生的 `target`、`property`、`from`、`to`、`duration`、`start()`、`restart()` 和 `stop()`，可嵌入 `Behavior`、`Transition`、`ParallelAnimation`、`SequentialAnimation`。

| 组件 | 默认属性 | 效果与节奏 |
| --- | --- | --- |
| `MotionAnimation` | 由调用方或 Behavior 指定 | 通用数值/进度，使用 `Theme.motion.standard` |
| `ThemeColorAnimation` | 由调用方或 Behavior 指定 | 颜色过渡，使用 `Theme.motion.linear` |
| `FadeAnimation` | `opacity` | 透明度过渡，使用 `Theme.motion.standard` |
| `SlideAnimation` | `y` | 垂直滑动，使用 `Theme.motion.standard`；`property: "x"` 改为水平 |
| `ScaleAnimation` | `scale` | 围绕目标的 `transformOrigin` 缩放，使用 `Theme.motion.standard` |
| `BounceAnimation` | `y` | 使用 `Theme.motion.bounce`，标准预设为 Qt `OutBounce` 落地回弹 |

所有组件通过 `motion: Theme.motion.accelerate` 等选择动效角色，业务组件不另写缓动曲线。数值动画的 `durationMultiplier` 用于局部时长倍率，例如演示的慢速观察；用户 `motionScale` 为 `0` 时仍直接完成。壁纸淡入、图表采样和播放波形有自己的配置时长或周期，可显式覆盖 `duration` 并乘以 `Theme.motion.scale`。

只有缓动类型为 `BezierSpline` 时才向 Qt 设置控制点，避免控制点赋值把 `OutBounce` 等原生曲线覆盖掉。

## 实际界面接入

- `PopupPanel` 用 `MotionAnimation` 驱动统一进度，入场取 `standard`、退场取 `accelerate`；位置和退场透明度共享进度。入场保持不透明以避免空白模糊块，关闭时先移除模糊区域，等动画实际结束并留出最后一帧提交时间后再释放窗口。快速重开会取消待释放操作。
- `ModalWindow`、OSD、菜单与交互状态层用 `FadeAnimation`，开关位移用 `SlideAnimation`，背景及边框颜色用 `ThemeColorAnimation`。
- `MorphPill` 和壁纸交叉淡入使用 `symmetric`，认证错误抖动使用 `feedback`，滚轮使用 `scroll`，图表连续更新和播放波形使用 `linear`。

新增数值或颜色动画使用这里的组件；具体角色、曲线和基础时长在主题动效预设中管理。窗口生命周期、错误反馈触发、壁纸加载完成等业务时机由原功能组件负责。

组件不预设起止值：独立播放时填写 `from`/`to`；在 `Behavior` 或 `Transition` 中由 Qt 推导，因此中途反向切换会从当前状态继续。`stop()` 保留当前值，`restart()` 从显式 `from` 重播。组件只改变数值，不负责 `visible`、焦点或窗口关闭；淡出后关闭窗口应由调用方在 `onFinished` 中处理。

## 跟随状态淡入淡出

```qml
import "../../ui/animations"

Item {
    property bool revealed: false
    opacity: revealed ? 1 : 0
    enabled: revealed
    Behavior on opacity { FadeAnimation {} }
}
```

透明度为零的对象仍参与布局与输入；示例同步设置 `enabled` 防止隐藏内容接收输入。

## 淡入与滑动组合

```qml
import "../../theme"
import "../../ui/animations"

Item {
    id: panel
    anchors.centerIn: parent
    transform: Translate { id: offset }

    ParallelAnimation {
        id: enter
        FadeAnimation { target: panel; from: 0; to: 1 }
        SlideAnimation { target: offset; from: Theme.spacing.section; to: 0 }
        ScaleAnimation { target: panel; from: 0.9; to: 1 }
    }

    Component.onCompleted: enter.start()
}
```

锚定或由 `Layout` 管理的元素应把位移动画作用于 `Translate`，不要直接动画 `x`/`y`，以免与布局争夺坐标。上下左右通过 `property` 与起止值选择；例如左侧滑入用 `property: "x"; from: -Theme.spacing.section; to: 0`。将 `SlideAnimation` 换成 `BounceAnimation` 即可获得回弹入场；缩放回弹可用 `BounceAnimation { target: panel; property: "scale"; from: 0.8; to: 1 }`。

## 交互演示

在 QuickShell 模块根目录运行：

```sh
qs -p animations.qml
```

点击四张卡片分别重播，或使用“全部重播”；“慢速观察”将本页时长乘以三，不写入外观设置。窗口变窄时切换为单列，内容可滚动。

演示入口与 `shell.qml` 同处模块根目录：QuickShell 以入口所在目录作为配置根，跨出该目录的相对导入无法正常解析。`bash tests/AnimationDemoTest.sh` 直接启动此入口，检查配置能否独立加载。
