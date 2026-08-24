-- Hyprland Nvidia 显卡环境与光标配置
-- 参考：https://wiki.hyprland.org/Nvidia/

hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia") -- 若屏幕共享异常可注释此行
hl.env("NVD_BACKEND", "direct")               -- 需要 libva-nvidia-driver
hl.env("GBM_BACKEND", "nvidia-drm")           -- 若 Firefox 崩溃可注释此行

hl.config({
    cursor = {
        no_hardware_cursors = true,           -- 避免光标卡顿
        -- allow_dumb_copy = true,
    },
})
