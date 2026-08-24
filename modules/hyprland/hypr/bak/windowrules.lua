-- 窗口规则
-- 参考 https://wiki.hypr.land/Configuring/Basics/Window-Rules/

-- 系统对话框与弹窗浮动并居中
hl.window_rule({
    name   = "open-files-dialog",
    match  = { title = "^(Open [Ff]iles?)" },
    float  = true,
    center = true,
})

hl.window_rule({
    name   = "open-files-dialog-cn",
    match  = { title = "^(打开?)" },
    float  = true,
    center = true,
})

hl.window_rule({
    name   = "open-folder-dialog",
    match  = { title = "^(Open [Ff]older)" },
    float  = true,
    center = true,
})

hl.window_rule({
    name   = "save-file-dialog",
    match  = { title = "^(Save [Ff]ile)" },
    float  = true,
    center = true,
})

hl.window_rule({
    name   = "save-as-dialog",
    match  = { title = "^(Save [Aa]s)" },
    float  = true,
    center = true,
})

hl.window_rule({
    name   = "wechat-preview",
    match  = { class = "^(wechat)$", title = "^(预览)$" },
    float  = true,
    center = true,
})

hl.window_rule({
    name   = "wechat-media",
    match  = { class = "^(wechat)$", title = "^(图片和视频)$" },
    center = true,
})

hl.window_rule({
    name   = "location-dialog",
    match  = { title = "^(Location)$" },
    center = true,
})

hl.window_rule({
    name   = "vscode-center",
    match  = { class = "^(Code)$" },
    center = true,
})

hl.window_rule({
    name    = "pavucontrol-float",
    match   = { class = "^(org.pulseaudio.pavucontrol)$" },
    float   = true,
    opacity = "0.80 0.70",
})

hl.window_rule({
    name    = "blueman-float",
    match   = { class = "^(blueman-manager)$" },
    float   = true,
    opacity = "0.80 0.70",
})

hl.window_rule({
    name    = "code-opacity",
    match   = { class = "^(code)$" },
    opacity = "1.00 1.00",
})

hl.window_rule({
    name    = "code-url-handler-opacity",
    match   = { class = "^(code-url-handler)$" },
    opacity = "0.80 0.80",
})

-- Edge (Wayland) 工具提示：短暂的空 class/title 顶层窗口会导致平铺重排/闪烁
-- Edge Wayland 弹窗路径的客户端 bug；浮动 + 不抢占焦点可缓解布局闪烁
hl.window_rule({
    name              = "empty-class-tooltip-float",
    match             = { class = "^$", title = "^$", initial_class = "^$", initial_title = "^$" },
    float             = true,
    no_initial_focus  = true,
    no_focus          = true,
})

hl.window_rule({
    name              = "empty-class-title-tooltip-float",
    match             = { class = "^$", title = "^$" },
    float             = true,
    no_initial_focus  = true,
    no_focus          = true,
})
