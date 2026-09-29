# QuickShell 桌面壳

本目录是 APM 的 QuickShell 配置，基于 QuickShell 0.3.1 和 Qt/QML，提供桌面状态栏、启动器、通知中心、OSD、窗口切换器、Polkit 原生身份认证模态框及统一主题外观系统。

## 入口

- `shell.qml`：生产入口，负责常驻服务初始化、多屏窗口装配，以及焦点/工作区变化时关闭弹窗的桌面策略。
- `tests.qml`：测试入口，通过 QuickShell 运行 `tests/` 下的行为与集成测试。

## 目录结构

```text
config/                 统一配置服务 (ConfigService/ConfigSchema)、外观设置 (AppearanceSettings)、桌面外壳设置 (ShellSettings)、壁纸设置 (WallpaperSettings)
config.default.jsonc    开箱即用的用户统一配置模板 (可复制为 config.jsonc 或 config.json 进行自定义)
features/<domain>/      按用户功能组织的视图、控制器、Provider 和 Store
features/bar/           状态栏装配及工作区、任务栏、网络等栏内组件
shared/                跨功能、无 UI 副作用的纯 JS 工具
services/               系统服务门面（音频、蓝牙、媒体、亮度、指标、桌面主题同步等）
services/windowmanager/ 窗口管理后端契约、Niri/Hyprland 实现和领域对象
theme/                  完整主题协议与设计令牌入口；详见 theme/README.md
theme/colors/           配色协议、预设（含深浅变体）及颜色计算
theme/materials/        材质、边框、阴影与高光协议、预设及计算
theme/geometry/         圆角、间距、密度协议、预设及缩放
theme/typography/       字体、字号、字重协议、预设及计算
theme/motion/           单项动效、动效组协议、预设及缩放
theme/components/       基础参数组合出的按钮、弹窗等组件样式
theme/themes/           完整主题组合 (FlatTheme, NeumorphicTheme, FrostedGlassTheme, LiquidGlassTheme)
theme/appearance/       外观修改入口与系统深浅模式解析
ui/controls/            可复用按钮、文字、图标、滑块、开关等基础控件
ui/containers/          InteractiveCard、弹窗、模态窗口、遮罩和栏分组等容器
ui/controllers/         跨功能的弹窗、提示、滚动和确认状态协调器
ui/charts/              可复用图表组件 (ArcGauge, Sparkline)
ui/effects/             表面底框 (SurfaceFrame)、交互状态层 (StateLayer)、合成器模糊
tests/                  行为测试与测试脚本检查
```

每个可复用 QML 目录都有 `qmldir`，新增类型时同步导出清单。`shell.qml` 直接承担少量启动装配；小模块在所属功能目录内组织，不额外增加只有转发作用的层。音频、蓝牙、主题、会话功能各提供自己的 Indicator，StatusBar 负责排列组合。

`ActionButton` 负责主操作、危险操作等按钮语义；通知、主题和窗口卡片使用 `InteractiveCard`。两者共享 SurfaceFrame 和 Qt 原生交互能力，卡片保持主题材质，不继承按钮的实体底色规则。`ui/controllers/PopupCoordinator` 只管理弹窗互斥和屏幕归属，不依赖系统服务。

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
       └──> ThemeSyncService ──> sync-desktop-theme.sh ──> (GTK / Kitty / Niri / Hyprland)
```

1. **持久化源头 (Persistence)**：`config/AppearanceSettings.qml`（对应 `~/.local/state/quickshell/appearance.json`）是外观配置的唯一真实来源。除 `Theme`（读取）和 `ThemeController`（写入）外，禁止任何 UI 或业务模块直接读写该配置。
2. **状态变异网关 (Mutator)**：`theme/appearance/ThemeController.qml` 是唯一的状态修改网关，集中校验并处理主题、调色板、深浅模式、强调色和缩放因子的修改。
3. **设计令牌门面 (Runtime Tokens)**：`theme/Theme.qml` 是唯一的消费入口。功能模块和基础 UI 统一且仅能通过 `Theme` 获取颜色、排版、间距、形状、动效与组件 tokens。
4. **外部环境同步 (Desktop Sync)**：`services/ThemeSyncService.qml` 监听 `Theme` 变动，通过 `scripts/sync-desktop-theme.sh` 联动同步 GTK、Kitty 终端配色、Niri/Hyprland 边框颜色；Niri 通过整文件原子生成外链 `theme-colors.kdl`（include 字段级合并覆盖主配置颜色默认值，watcher 自动重载）实现。
5. **用户声明式配置 (User Config)**：`config/ConfigService.qml` 按“读取 → JSONC 解析 → 深合并 → `ConfigSchema` 规范化”处理当前模块根目录下的 `config.jsonc` 或 `config.json`（基于模板 `config.default.jsonc`），提供工作区自适应划分、壁纸目录探测、终端与锁屏命令、通知参数的热重载支持；各领域设置（`ShellSettings`, `WallpaperSettings`）作为领域门面对外提供安全降级与统一消费。

配置层全部读取、解析成功后才整体生效；读取或解析失败保留上次有效配置，并记录 `ConfigService.lastError`。初次加载失败使用内置默认值；缺失或空文件不提供覆盖项。

持久化只使用当前格式，不导入旧版主题选择、壁纸语义或旧启动器历史。启动器历史以 Provider 的精确 key 索引，记录 `{ count, lastUsed }`；不按显示名称或文件后缀猜测匹配。

主题同步复用 CommandQueue：正在执行的请求完成后，仅执行最新的待处理请求；`ThemeSyncService.syncing`、`lastExitCode` 和 `syncFinished` 提供执行状态。脚本逐个尝试可用目标，汇总失败并返回非零。

## 设计令牌体系 (Design Tokens)

- **颜色 (`Theme.colors.*`)**：
  - 基础语义：`background`, `surface`, `surfaceVariant`, `outline`, `scrim`
  - 文本与图标：`textPrimary`（高对比主文本与图标）, `textSecondary`（次级说明文字）, `disabledText`
  - 状态反馈：`danger`, `warning`, `success`, `info`, `dangerForeground`, `dangerContainer`
  - 强调色：`accent`, `accentForeground`, `accentContainer`, `focusRing`, `selectedSurface`, `hoveredSurface`
- **排版 (`Theme.typography.*`)**：
  - 字体角色：`small`(10), `caption`(11), `body`(12), `title`(15), `heading`(20)，每个角色是包含 `family`、`pixelSize`、`weight` 等属性的 QML 字体对象，字号乘 `Theme.fontScale`
  - 文本字体默认使用用户设置（SpaceMono Nerd Font）；`iconFamily` 为图标字体（SpaceMono Nerd Font Propo）
  - 使用 `font: Theme.typography.body` 绑定完整样式，或用 `Theme.typography.body.pixelSize` 读取单项
- **间距 (`Theme.spacing.*`)**：
  - `tiny`(2), `small`(4), `medium`(8), `large`(12), `extraLarge`(16), `section`(20)（均受主题 `density` 与 `spacingScale` 缩放）
- **形状与透明度 (`Theme.shape.*` / `Theme.disabledOpacity`)**：
  - `smallRadius`(4), `controlRadius`(8), `panelRadius`(12), `roundRadius`(26)（均乘 `Theme.shape.scale`），`borderWidth`，`focusBorderWidth`
  - 全局禁用态不透明度：`Theme.disabledOpacity`(0.45)
- **动效 (`Theme.motion.*`)**：
  - `fastEffects`, `standard`, `slowEffects`, `spatial`, `scroll`（均含 `duration`、`easing` 与 `curve` 贝塞尔曲线参数）
- **材质 (`Theme.surface.*`)**：填充、边框、阴影、高光与玻璃效果参数，供各类控件统一使用。
- **组件专用令牌 (`Theme.components.*`)**：
  - `bar`, `barGroup`, `barButton`, `actionButton`, `actionRow`, `sectionHeader`, `arcGauge`, `toggleSwitch`, `iconButton`, `popup`, `slider`, `status`, `calendar`, `themeCard`, `colorModeToggle`, `notification`, `bluetooth`, `menu`
  - `actionRow.minHeight` / `actionButton.minHeight` 是控件最小高度；实际高度由内容和布局决定。保留组件命名分组，内部重复引用可使用有类型的 `_tokens`，详见 `theme/README.md`。

## 主题与配色机制

- **主题 (`ThemeDefinition`)**：组合配色、材质、几何、排版和动效。协议位于各领域根部，`presets/` 提供成套的小样式（如材质组合表面、边框和阴影），`runtime/` 接收明确输入并计算最终值；默认值及单参数变化直接配置，不另建预设。已注册主题：`neumorphic`（默认，柔和阴影立面）、`flat`（清晰边框扁平）、`frosted-glass`（磨砂玻璃，透光朦胧、镜面微边与亚克力磨砂质感）、`liquid-glass`（液态玻璃，高通透清澈水体、360° 全周菲涅尔内光晕、天光透镜弧面反光与灵动大圆角）。
- **配色家族 (`PaletteDefinition`)**：表示色彩家族。已注册配色：`pastel-relief`（默认）、`catppuccin`、`nord`、`everforest`、`tokyo-night`。
- **色彩变体 (`PaletteVariant`)**：每个调色板提供成对的 `light` 与 `dark`语义颜色及多个候选强调色（Accents）。
- **独立正交原则**：
  - 每个主题组合一个默认配色对象；用户显式选择的配色优先，未指定或无效时使用主题默认值。
  - 配色面板可选择“跟随主题”，清空显式配色选择并持久化；新用户默认跟随，已有选择保持有效。
  - 切换主题不会重置配色家族、明暗模式或强调色；切换配色家族亦不改变主题。
  - `colorMode` 支持 `system`（由 `ColorModeResolver` 动态解析）、`light`、`dark`。

## IPC 命令

通过 `qs ipc call <target> <method> [args...]` 执行控制：

| 目标 (`target`) | 方法 (`method`) | 参数说明 |
| :--- | :--- | :--- |
| `theme` | `setTheme` | `<id>`: `flat` / `neumorphic` / `frosted-glass` / `liquid-glass` |
| `theme` | `setPalette` | `<id>`: `pastel-relief` / `catppuccin` / `nord` / `everforest` / `tokyo-night` |
| `theme` | `resetPalette` | 恢复跟随主题默认配色，保持深浅模式与强调色选择 |
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
| `theme-sync` | `sync` | 请求外部桌面主题同步；返回值表示是否接受，执行结果由服务状态及日志反馈 |
| `polkit` | `test` | `[message] [actionId]`: 调起测试认证模态框以预览毛玻璃 UI |
| `polkit` | `cancel` | 关闭/取消当前认证模态框 |

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
bash tests/RunnerTest.sh
bash tests/ThemeSyncTest.sh
scripts/run-tests.sh
```

生产切换前，应在隔离的 Niri 环境中检查多屏栏、启动器、主题缩放和通知窗口；可在 Xvfb 内启动嵌套 Niri。单独的 Xvfb/X11 环境无法覆盖基于 Wayland PanelWindow 的主题弹窗测试。

测试脚本为每次运行创建独立状态目录，结束时清理；它检查所有已登记测试套件的完成情况和失败计数，错误、未完成或超时均返回非零。默认超时 60 秒，可通过 `APM_QUICKSHELL_TEST_TIMEOUT` 调整。

`ThemeSyncTest.sh` 使用模拟命令验证连续请求合并、完成状态和部分目标失败，不修改真实桌面配置。
