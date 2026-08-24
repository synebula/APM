-- 用户偏好：环境变量与 misc 设置

hl.env("XCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("XCURSOR_SIZE", "18")
hl.env("HYPRCURSOR_THEME", "Bibata-Modern-Classic")
hl.env("HYPRCURSOR_SIZE", "18")

hl.config({
    misc = {
        vrr = 0,
        focus_on_activate = true, -- 应用请求激活时自动切换焦点
    },
})
