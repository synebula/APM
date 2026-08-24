-- Hyprland Lua 配置入口（由 hyprlang .conf 迁移而来）
-- 参考：https://wiki.hypr.land/Configuring/Start/

require("userprefs")
require("monitors")
require("animations")
require("theme")
require("windowrules")
require("keybindings")
require("nvidia")

-- 默认显示器规则（未单独配置的显示器使用此规则）
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

-- 启动时执行
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")                                        -- 状态栏
    hl.exec_cmd("blueman-applet")                                -- 蓝牙托盘
    hl.exec_cmd("swaync")                                        -- 通知守护
    hl.exec_cmd("fcitx5 -d -r")                                  -- 输入法
    hl.exec_cmd("hyprpaper")                                     -- 壁纸
    hl.exec_cmd("systemctl --user start hyprpolkitagent")        -- 认证对话框
    hl.exec_cmd("/home/alex/app/rti -token thisisrtitoken")
end)

hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",
        follow_mouse = 0,      -- 0 = 禁用, 1 = 启用, 2 = 仅鼠标悬停窗口时
        sensitivity = 0,       -- -1.0 - 1.0, 0 表示不修改
        force_no_accel = true,
        numlock_by_default = true,
        touchpad = {
            natural_scroll = false,
        },
    },
    misc = {
        vrr = 0,
    },
})

-- 如需关闭 Hyprland 的更新/捐赠提醒弹窗，取消下面注释：
-- hl.config({
--     ecosystem = {
--         no_update_news = true,
--         no_donation_nag = true,
--     },
-- })
