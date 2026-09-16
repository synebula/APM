# QuickShell 桌面壳

本目录是 APM 的 QuickShell 配置，基于 QuickShell 0.3.1 和 Qt/QML，提供桌面状态栏、启动器、通知中心、OSD、窗口切换器及统一主题外观系统。

## 入口

- `shell.qml`：生产入口，负责组合各个窗口和多屏状态栏。
- `tests.qml`：测试入口，通过 QuickShell 运行 `tests/` 下的行为与集成测试。

## 目录结构

```text
config/                 持久化外观设置 (AppearanceSettings) 和桌面布局设置 (ShellSettings)
features/<domain>/      按用户功能组织的视图、控制器、Provider 和 Store
services/               系统服务门面（音频、蓝牙、媒体、亮度、指标、桌面主题同步等）
services/windowmanager/ 窗口管理后端契约、Niri/Hyprland 实现和领域对象
theme/                  主题定义、配色调色板、变体、设计令牌门面与控制器
theme/palettes/         配色家族定义 (Catppuccin, Everforest, Nord, PastelRelief, TokyoNight)
theme/variants/         各配色家族的 light / dark 语义色及强调色变体
theme/themes/           外观风格定义 (FlatTheme, NeumorphicTheme)
ui/controls/            可复用按钮、文字、图标、滑块、开关等基础控件
ui/containers/          弹窗、模态窗口、遮罩和栏分组等容器
ui/controllers/         跨功能的弹窗、提示、滚动和确认状态协调器
ui/charts/              可复用图表组件 (ArcGauge, Sparkline)
ui/effects/             表面底框 (SurfaceFrame)、交互状态层 (StateLayer)、合成器模糊
tests/                  QuickShell 行为测试与主题断言
```

每个可复用 QML 目录都有 `qmldir`。它既是 QML 模块的导出清单，也是该目录对外暴露的边界；新增类型时应同步更新对应文件。

## 架构依赖与单一事实来源 (SSOT)

```text
[appearance.json]
       │ (读写)
[AppearanceSettings] <── (唯一写入口) ── [ThemeController] (IPC / UI交互)
       │ (只读)
    [Theme] (全局唯一设计令牌门面)
       ├── ThemeCatalog (ThemeDefinition: Flat / Neumorphic 等风格 Specs)
       ├── PaletteCatalog (PaletteDefinition / PaletteVariant: 颜色家族与变体)
       └── ColorModeResolver (系统 Portal / GSettings / Darkman 嗅探)
       │
       ├──> features/ & ui/ (设计令牌消费)
       └──> ThemeSyncService ──> sync-desktop-theme.sh ──> (GTK / Kitty / Hyprland)
```

1. **持久化源头 (Persistence)**：`config/AppearanceSettings.qml`（对应 `~/.local/state/quickshell/appearance.json`）是外观配置的唯一真实来源。除 `Theme`（读取）和 `ThemeController`（写入）外，禁止任何 UI 或业务模块直接读写该配置。
2. **状态变异网关 (Mutator)**：`theme/ThemeController.qml` 是唯一的状态修改网关，集中校验并处理主题、调色板、深浅模式、强调色和缩放因子的修改。
3. **设计令牌门面 (Runtime Tokens)**：`theme/Theme.qml` 是唯一的消费入口。功能模块和基础 UI 统一且仅能通过 `Theme` 获取颜色、排版、间距、形状、动效与组件 tokens。
4. **外部环境同步 (Desktop Sync)**：`services/ThemeSyncService.qml` 监听 `Theme` 变动，通过 `scripts/sync-desktop-theme.sh` 联动同步 GTK、Kitty 终端配色和 Hyprland 边框颜色。

## 设计令牌体系 (Design Tokens)

- **颜色 (`Theme.colors.*`)**：
  - 基础语义：`background`, `surface`, `surfaceVariant`, `outline`, `scrim`
  - 文本与图标：`textPrimary`（高对比主文本与图标）, `textSecondary`（次级说明文字）, `disabledText`
  - 状态反馈：`danger`, `warning`, `success`, `info`, `dangerForeground`, `dangerContainer`
  - 强调色：`accent`, `accentForeground`, `accentContainer`, `focusRing`, `selectedSurface`, `hoveredSurface`
- **排版 (`Theme.typography.*`)**：
  - 字体族：`family`（文本字体，SpaceMono Nerd Font）, `iconFamily`（图标字体，SpaceMono Nerd Font Propo）
  - 标准字号：`smallSize`(10), `captionSize`(11), `bodySize`(12), `titleSize`(15), `headingSize`(20)（均乘 `Theme.fontScale`）
  - 复合字体对象：`body`, `caption`, `title`
- **间距 (`Theme.spacing.*`)**：
  - `tiny`(2), `small`(4), `medium`(8), `large`(12), `extraLarge`(16), `section`(20)（均受主题 `density` 与 `spacingScale` 缩放）
- **形状 (`Theme.shape.*`)**：
  - `smallRadius`(4), `controlRadius`(8), `panelRadius`(12), `roundRadius`(26)（均乘 `Theme.shape.scale`），`borderWidth`
- **动效 (`Theme.motion.*`)**：
  - `fastEffects`, `standard`, `slowEffects`, `spatial`, `scroll`（均含 `duration`、`easing` 与 `curve` 贝塞尔曲线参数）
- **组件专用令牌 (`Theme.components.*`)**：
  - `surface`, `bar`, `barGroup`, `barButton`, `actionButton`, `actionRow`, `toggleSwitch`, `iconButton`, `popup`, `slider`, `status`, `calendar`, `themeCard`, `colorModeToggle`, `notification`

## 主题与配色机制

- **主题 (`ThemeDefinition`)**：组合形状、边框、层级、表面、间距、字体和动效规范。已注册主题：`neumorphic`（默认，柔和阴影立面）、`flat`（清晰边框扁平）。
- **配色家族 (`PaletteDefinition`)**：表示色彩家族。已注册配色：`pastel-relief`（默认）、`catppuccin`、`nord`、`everforest`、`tokyo-night`。
- **色彩变体 (`PaletteVariant`)**：每个调色板提供成对的 `light` 与 `dark` 语义颜色及多个候选强调色（Accents）。
- **独立正交原则**：
  - 切换主题不会重置配色家族、明暗模式或强调色；切换配色家族亦不改变主题。
  - `colorMode` 支持 `system`（由 `ColorModeResolver` 动态解析）、`light`、`dark`。

## IPC 命令

通过 `qs ipc call <target> <method> [args...]` 执行控制：

| 目标 (`target`) | 方法 (`method`) | 参数说明 |
| :--- | :--- | :--- |
| `theme` | `setTheme` | `<id>`: `flat` / `neumorphic` |
| `theme` | `setPalette` | `<id>`: `pastel-relief` / `catppuccin` / `nord` / `everforest` / `tokyo-night` |
| `theme` | `setColorMode` | `<mode>`: `system` / `light` / `dark` |
| `theme` | `toggleColorMode` | 快速在深色与浅色之间切换 |
| `theme` | `setAccent` | `<id>`: 当前配色支持的 accent 名称（如 `blue`, `lavender`, `green`） |
| `theme` | `resetColors` | 重置当前变体的默认强调色 |
| `theme` | `nextPalette` | 循环切换下一个配色方案 |
| `theme` | `nextAccent` | 循环切换下一个强调色 |
| `theme` | `setFontScale` | `<value>`: 0.75 ~ 2.0 |
| `theme` | `setRadiusScale`| `<value>`: 0.0 ~ 3.0 |
| `theme` | `setSpacingScale`| `<value>`: 0.5 ~ 2.0 |
| `theme` | `setMotionScale` | `<value>`: 0.0 ~ 4.0 |
| `theme-sync` | `sync` | 立即触发一次外部桌面主题同步 |

## 编码规范与陷阱约束

- **严禁使用 `on[A-Z]*` 命名任何属性**：
  - **禁忌**：禁止定义如 `onSurface`、`onAccent`、`onPrimary`、`onBackground` 等属性。
  - **根因**：QML 引擎强制将所有以 `on` 开头且紧跟大写字母的标识符识别为信号处理器（Signal Handler），会导致该属性被静默拦截并回退为默认空值（color 回退为纯黑 `#000000`）。
  - **规范**：高对比前景色一律采用 `*Foreground` 或 `*Text` 规范命名（如 `accentForeground`、`disabledText`）。
- **设计令牌与控件前景色收敛**：
  - 常规前景色统一使用 `Theme.colors.textPrimary` 和 `Theme.colors.textSecondary`，亮暗模式由调色板自动切换。
  - 容器与按钮控件（如 `BarButton`、`ActionButton`、`ActionRow`）统一对外暴露 `foreground` 属性；子组件只需绑定容器的 `foreground`，严禁在业务组件中硬编码颜色。
  - 基础文本与图标控件（如 `TextLabel`、`BarText`、`IconGlyph`）**禁止在 `color` 上挂载 `Behavior on color`**，防止组件实例化阶段从 Qt 默认黑色产生过渡滞后或值冻结。
  - 尺寸、外边距与间距一律采用 `Theme.spacing.*`，圆角一律采用 `Theme.shape.*`，严禁在组件中写入未定义的设计数值。

## 验证

```sh
qmllint shell.qml tests.qml
qs -p tests.qml
```

生产切换前，应在隔离的 Niri 或 Xvfb 环境中检查多屏栏、启动器、主题缩放和通知窗口。
