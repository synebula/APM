-- 主题：布局、边框与装饰
-- 参考 https://wiki.hypr.land/Configuring/Layouts/Dwindle-Layout/

hl.config({
    dwindle = {
        preserve_split = true,
    },

    general = {
        gaps_in  = 2,
        gaps_out = 4,
        border_size = 2,
        col = {
            active_border   = { colors = { "rgba(dc8a78ff)", "rgba(8839efff)" }, angle = 45 },
            inactive_border = { colors = { "rgba(7287fdcc)", "rgba(179299cc)" }, angle = 45 },
        },
        layout = "dwindle",
        resize_on_border = true,
    },

    decoration = {
        rounding = 10,
        blur = {
            enabled = true,
            size = 6,
            passes = 3,
            new_optimizations = true,
            ignore_opacity = true,
            xray = false,
        },
    },
})
