-- 显示器与工作区分配
-- 参考 https://wiki.hypr.land/Configuring/Basics/Monitors/

hl.monitor({
    output   = "HDMI-A-2",
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = "1",
})

hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@60",
    position = "0x1080",
    scale    = "1",
})

-- 工作区绑定到显示器
local ws_hdmi1 = { 1, 2, 3, 4, 5, 11, 12, 13 }
for _, id in ipairs(ws_hdmi1) do
    hl.workspace_rule({ workspace = tostring(id), monitor = "HDMI-A-1" })
end

local ws_hdmi2 = { 6, 7, 8, 9, 10 }
for _, id in ipairs(ws_hdmi2) do
    hl.workspace_rule({ workspace = tostring(id), monitor = "HDMI-A-2" })
end
