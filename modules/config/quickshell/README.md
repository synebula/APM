# QuickShell 桌面壳

本目录是 APM 的 QuickShell 配置，基于 QuickShell 0.3.1 和 Qt/QML，提供桌面状态栏、启动器、通知、OSD、窗口切换器及主题系统。

## 入口

- `shell.qml`：生产入口，负责组合各个窗口和多屏状态栏。
- `tests.qml`：测试入口，通过 QuickShell 运行 `tests/` 下的行为测试。

## 目录结构

```text
config/                 持久化外观设置和桌面布局设置
features/<domain>/      按用户功能组织的视图、控制器、Provider 和 Store
services/               系统服务门面（音频、蓝牙、媒体、亮度、指标等）
services/windowmanager/ 窗口管理后端契约、Niri/Hyprland 实现和领域对象
theme/                  主题定义、可选配色方案，以及字体、间距、形状、动效和组件 tokens
ui/controls/            可复用按钮、文字、图标、滑块等基础控件
ui/containers/          弹窗、模态窗口、遮罩和栏分组等容器
ui/controllers/         跨功能的弹窗、提示和确认状态协调器
ui/charts/              可复用图表组件
tests/                  QuickShell 行为测试
```

每个可复用 QML 目录都有 `qmldir`。它既是 QML 模块的导出清单，也是该目录对外暴露的边界；新增类型时应同步更新对应文件。

## 依赖方向

```text
shell.qml
   └── features  ──> services
          │             └── windowmanager backends
          ├──> theme
          └──> ui
```

功能模块可以使用服务、主题和共享 UI。服务不依赖功能视图；共享 UI 应保持通用，只有跨窗口协调确实需要时才访问服务。

全局服务和主题使用 QML `Singleton`。新增服务优先放入 `services/`，新增用户功能优先放入对应的 `features/<domain>/`，不要把领域逻辑放入 `ui/`。

## 命名约定

- QML 类型使用 PascalCase，文件名与类型名一致。
- `*Service` 表示系统服务，`*Controller` 表示交互协调，`*Store` 表示持久化或集合状态。
- 展示组件使用 `*Window`、`*Popup`、`*Indicator` 或 `*View`。
- 颜色、尺寸和动效从 `Theme` 读取；功能模块不要重复定义设计 token。

### QML 属性与 Token 命名约束（严防语法陷阱）

- **严禁使用 `on[A-Z]*` 命名任何属性**：
  - **禁忌**：禁止定义如 `onSurface`、`onAccent`、`onPrimary`、`onBackground` 等属性。
  - **根因**：QML 语法引擎强制将所有以 `on` 开头且紧跟大写字母的标识符识别为**信号处理器（Signal Handler）**。若对象中存在同名信号或属性（如 `surface`、`accent`），该属性声明会被拦截为信号处理槽，导致其作为属性读取时永远静默失效并回退为默认空值（对于 `color` 类型将回退为 `QColor(0,0,0)` 即纯黑 `#000000`）。
  - **规范**：容器或状态背景上的高对比前景色一律采用 `*Foreground` 或 `*Text` 规范命名，例如 `accentForeground`、`dangerForeground`、`disabledText`。
- **设计令牌与控件前景色收敛**：
  - 常规前景色统一使用 `Theme.colors.textPrimary`（主文本与图标）和 `Theme.colors.textSecondary`（次级说明文字），亮暗模式由调色板自动切换。
  - 容器与按钮控件（如 `BarButton`、`ActionButton`、`ActionRow`）统一对外暴露 `foreground` 属性；业务委托或子组件只需绑定容器的 `foreground` 或直接使用默认前景色，严禁逐个业务组件硬编码颜色。
  - 基础文本控件（如 `TextLabel`、`BarText`）禁止在 `color` 上挂载 `Behavior on color`，防止组件实例化阶段从 Qt 默认黑色产生过渡滞后或值冻结。


## 主题与配色

主题是外观语言的主入口：`ThemeDefinition` 组合形状、边框、层级、表面、间距、字体和动效 token。`ThemeCatalog` 注册命名主题；推荐配色只用于预览和初始搭配，不参与主题运行时继承。主题 token 不包含具体颜色，也没有 `raised` 这类派生类别字段。

`Palette` 表示颜色家族，`PaletteVariant` 提供同一家族的 light/dark 语义颜色。`AppearanceSettings` 独立保存 `themeId`、`paletteId`、`colorMode` 与 `accentId`；`colorMode` 可选 `system`、`light`、`dark`，系统模式由 `ColorModeResolver` 解析。最终颜色由 palette、解析后的模式和强调色组合得到。

切换主题不会重置配色、明暗模式或强调色；切换 palette 也不会改变主题。选择器顶部通过开关切换深色和浅色，下面选择 palette 与强调色。“重置强调色”只清除 accent 选择。需要一键保存完整组合时，应在这些基础选择之上增加独立 preset，而不是把 palette 绑定回主题。

IPC `theme setTheme <id>`、`theme setPalette <id>`、`theme setColorMode <system|light|dark>` 和 `theme setAccent <id>` 分别修改单项，`theme resetColors` 清除强调色选择；`theme nextPalette` 和 `theme nextAccent` 用于循环选择。

## 验证

```sh
qmllint shell.qml tests.qml
qs -p tests.qml
go run .agents/validate_quickshell_tests.go -log <test-log>
```

生产切换前，应在隔离的 Niri 或 Xvfb 环境中检查多屏栏、启动器、主题缩放和通知窗口。
