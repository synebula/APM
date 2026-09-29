# 主题模块

主题按领域组织：协议定义结构，`presets/` 提供成套的领域样式，完整 Theme 组合这些样式，`runtime/` 计算最终值。

```text
theme/
├── ThemeDefinition.qml       完整主题的组合协议
├── Theme.qml                 当前主题的装配与统一读取入口
├── colors/                   配色家族、深浅色变体、语义颜色
├── materials/                材质、边框、阴影、高光
├── geometry/                 圆角、间距、密度
├── typography/               字体、字号、字重、字距
├── motion/                   单项动效及动效组
├── components/               按钮、弹窗等组件的样式计算
├── themes/                   完整主题组合及 ThemeCatalog
└── appearance/               ThemeController、系统深浅模式解析
```

例如，`materials/MaterialSpec.qml` 组合表面、边框和阴影协议；`materials/presets/FrostedGlassMaterial.qml` 定义一套协调好的磨砂玻璃材质；完整主题再选择它与配色、几何、排版、动效搭配。

## 领域结构与预设

| 领域 | 协议结构 | 成套预设 |
| --- | --- | --- |
| colors | 配色家族 → 深浅变体 → 语义颜色 | Nord、Catppuccin 等 |
| materials | MaterialSpec → surface、border、elevation | FrostedGlassMaterial、LiquidGlassMaterial、NeumorphicMaterial |
| geometry | GeometrySpec → shape、spacing | RoundedGeometry、LargeRoundedGeometry，协调圆角与密度 |
| typography | TypographySpec → small、caption、body、title、heading | SoftTypography，正文微调字距，标题采用中等字重 |
| motion | MotionProfile → 六种动效角色 | StandardMotion，组合各角色的曲线与相对时长 |

默认协议提供完整可用的基础值，扁平主题直接使用默认材质、几何与排版。仅改变密度或整体时长时，在 Theme 中直接覆盖；不为默认值或单个常量创建预设文件。领域预设不绑定配色或主题 ID，可跨主题搭配，每次实例化独立持有子对象。

小型子协议以内联组件集中在领域协议文件中：`MaterialSpec.qml` 顶部声明整体结构，下面定义 `Surface`、`Border`、`Elevation`；`GeometrySpec.qml` 同样内联 `Shape`、`Spacing`。外部使用 `MaterialSpec.Border`、`GeometrySpec.Shape` 等限定类型名，仍可独立实例化和替换子对象。仅根类型注册到 `qmldir`；子类型有独立复用需求或实现复杂时再拆文件。

## 职责与依赖

| 位置 | 职责 | 依赖边界 |
| --- | --- | --- |
| 功能目录根部的协议 | 参数类型、基础默认值 | 不读取当前主题或用户设置 |
| `presets/` | 可复用的成套领域样式 | 依赖本领域协议，不读取其他领域或当前 Theme |
| `ThemeDefinition`、`themes/` | 组合配色、材质、几何、排版、动效 | 使用协议和领域预设，不依赖计算层 |
| `runtime/` | 缩放、颜色解析、深浅模式对应的效果参数 | 显式接收所需的协议对象和参数 |
| `components/` | 将基础样式组合为具体组件的状态样式 | 接收基础计算结果，不读取全局 Theme 或配置 |
| `Theme.qml` | 选择生效定义，连接配置与各计算模块 | 对 UI 提供稳定的只读入口 |
| `appearance/` | 校验修改、IPC、跟随系统 | 由 ThemeController 调用 AppearanceSettings 持久化 |

`ui/controls`、`ui/containers`、`ui/effects` 负责实际绘制和动画，读取 `Theme.colors`、`Theme.shape`、`Theme.spacing`、`Theme.typography`、`Theme.motion`、`Theme.components`。预设中的材质类型决定使用哪种绘制能力，具体主题 ID 不参与组件分支。

`Theme.surface` 使用 `materials/runtime/SurfaceTokens` 的计算结果；边框的宽度、透明度、颜色策略统一归材质领域管理。

固定业务图标（连接操作、深浅模式、菜单标记）由功能组件决定；组件样式只计算颜色、尺寸等视觉参数。

阴影、高光由 `elevation.shadowEnabled`、`elevation.highlightEnabled` 开关控制，效果由模糊、偏移和透明度参数决定。`SurfaceFrame` 接收 `surface` 与 `isDark`，默认使用当前 Theme，也可传入候选主题的计算结果。`ActionButton.materialEnabled` 按用途决定：启用的主按钮和选中按钮关闭材质，BarButton 的激活/紧急状态及配色色块也显式关闭，保持前景色与实体底色配对；通知、主题、窗口切换等卡片使用独立的 `InteractiveCard` 保留材质。不能仅凭 `fillColor.a` 判断用途，不透明的原始底色仍可能需要经过玻璃透明度、光带或拟物渐变处理。

主题卡片独立计算候选主题的 ColorTokens、ShapeTokens、SpacingTokens、SurfaceTokens，并复用 SurfaceFrame 绘制；预览使用候选主题的默认配色，跟随当前深浅模式和用户缩放。样例以候选配色的 surface 色绘制在 background 底板上，并启用 SurfaceFrame 自带的本地阴影；实际玻璃窗口的背景模糊仍由合成器提供。

## 公共读取接口

| 类别 | 入口示例 | 使用规则 |
| --- | --- | --- |
| 通用视觉参数 | `Theme.colors.accent`、`Theme.spacing.medium`、`Theme.surface.fill` | 表达颜色、间距、材质等跨组件能力 |
| 排版角色 | `Theme.typography.body`、`Theme.typography.title.pixelSize` | 直接绑定完整字体，或读取角色中的单个属性 |
| 组件专用样式 | `Theme.components.actionRow.minHeight` | 表达具体组件的尺寸与状态样式 |
| 控件实际尺寸 | `row.implicitHeight`、`row.height` | 由内容、布局和组件样式共同决定 |

保留 `components` 分组以区分基础参数与组件样式。对外不提供 `Theme.actionRow` 等扁平别名，也不重复暴露 `Theme.components.surface`；材质统一通过 `Theme.surface` 读取。

基础控件内部频繁引用同一组样式时，可以声明有类型的局部 `_tokens` 属性，例如 `readonly property ActionRowTokens _tokens: Theme.components.actionRow`。它保持响应式绑定，避免重复书写完整路径；业务视图通常直接使用封装好的控件。

尺寸名按用途命名：`minHeight` 是内容自适应高度的下限；`size` 是正方形控件尺寸；`iconContainerSize` 是图标容器尺寸。组件不得仅因数值相同而借用另一个组件的尺寸，例如标题图标使用 `sectionHeader.iconContainerSize`，仪表盘使用 `arcGauge.size`。刻意共享的设计尺度应先定义为基础参数，再由各组件引用。

## 主题组合

四个内置主题保留原有标识和视觉参数。每个主题组合独立的领域预设实例，并可局部覆盖，例如：

```qml
// themes/ 中的组合示意
ThemeDefinition {
    themeId: "custom"
    displayName: "自定义"
    glyph: "◈"
    description: "紧凑的玻璃主题"
    suggestedPaletteIds: ["nord"]

    palette: Nord {}
    material: FrostedGlassMaterial { border.opacity: 0.5 }
    geometry: RoundedGeometry { spacing.density: 1 }
    typography: SoftTypography { title.pixelSize: 16 }
    motion: StandardMotion { duration: 150 }
}
```

导入方式参考 `themes/FrostedGlassTheme.qml`。新增主题后更新 `themes/qmldir` 和 `themes/ThemeCatalog.qml`；新增领域预设或协议后同步对应目录的 `qmldir`。

只有需要复用的配置才提取为新预设。局部覆盖不会修改其他主题的实例。当前完整主题通过 QML 定义并注册；用户方案的 JSON 保存、加载及编辑界面尚未实现。

## 配色与个人设置

- 每个主题显式组合一个默认 `palette`；建议配色列表仅供展示。
- 用户保存的 `paletteId` 优先于主题默认配色；空值或无效值使用主题的配色对象。
- 配色面板的“跟随主题”及 `ThemeController.resetPalette()` 清空配色选择；`Theme.paletteFollowsTheme` 表示这一状态。重置保持深浅模式与强调色选择，随后切换主题会采用新主题的默认配色。新用户默认跟随，已有显式选择保持有效。
- 切换主题保持当前显式配色、深浅模式、强调色和个人缩放设置。
- 实际颜色直接从选中的配色对象计算，支持主题对配色实例做局部定制。
- `config/AppearanceSettings.qml` 是外观的持久化来源，`appearance.json` 使用空 `paletteId` 保存跟随状态。IPC 的 `theme resetPalette` 与界面执行同一操作。

## 动效与缩放

排版角色使用 QML 原生 `font` 类型，包含 `pixelSize`、`weight`、`letterSpacing`、`italic` 等属性。字体族按「角色 family → 排版公共 family → 用户字体设置」解析；未指定时使用空字符串。字号按像素定义，运行时缩放取整，其他字体属性原样保留。UI 直接绑定 `font: Theme.typography.title`，不再提供 `titleSize`、`titleWeight` 等重复入口。

TextLabel 默认应用完整 body 字体，SectionHeader 使用 title。局部强调使用 `Theme.typography.withOverrides(Theme.typography.body, { weight: Theme.typography.title.weight })`，复制字体后覆盖指定属性，保留其他参数并保持源角色不变。图标仍使用 iconFamily，仅按需要读取角色字号。

`MotionSpec` 描述单项动效的时长、曲线和缓动类型。`MotionProfile` 包含基础时长及 `fastEffects`、`standard`、`slowEffects`、`spatial`、`accelerate`、`scroll` 六个角色。

`motion/presets/StandardMotion.qml` 在一个文件中定义整组曲线和相对时长。完整主题通过 `StandardMotion { duration: 320 }` 调整整体节奏，也可覆盖单个角色。运行时只对各项时长应用用户倍率并取整，曲线和缓动类型直接来自预设。

预设时长允许小数，避免在缩放前提前取整。例如 `150 × 0.75 × 1.5` 的最终时长是 `169ms`。字体、间距和圆角同样在运行时使用原始定义计算，不回写预设。

## 验证

在 QuickShell 模块根目录执行：

```sh
qmllint shell.qml tests.qml
scripts/run-tests.sh
```

行为测试需在 Wayland 环境运行：主题弹窗基于 `PanelWindow`，Xvfb/X11 本身无法覆盖它，隔离测试可在 Xvfb 中启动嵌套 Niri。

`ThemeTest` 验证主题、配色、状态色、切换与持久化；`ThemeCompositionTest` 验证跨领域搭配、嵌套对象隔离、局部覆盖与整体替换、字体角色与字体族解析、动效曲线和缩放后的取整。

`ControlsTest` 采样四种主题、深浅模式和主按钮/选中/危险状态的实际背景像素检查文字对比度，并验证字体角色在真实控件上的生效与局部覆盖；通知卡片验证透明度、渐变、阴影及磨砂玻璃上下光边的真实像素，栏按钮验证激活/紧急状态的实体底色。`ThemeTest` 同时验证“跟随主题”的界面操作、持久化及候选材质预览的底色和阴影开关。
