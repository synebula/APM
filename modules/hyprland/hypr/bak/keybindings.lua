-- 按键绑定
-- 参考：https://wiki.hypr.land/Configuring/Basics/Binds/

local mainMod     = "SUPER" -- 徽标键
local terminal    = "kitty"
local fileManager = "nautilus"

------------------------------------------------
-- 主要操作
------------------------------------------------
hl.bind(mainMod .. " + C", hl.dsp.window.close())                                        -- 关闭当前聚焦窗口
hl.bind(mainMod .. " + CTRL + delete", hl.dsp.exit())                                    -- 退出桌面会话
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))                   -- 切换当前聚焦窗口为浮动
-- hl.bind(mainMod .. " + CTRL + L", hl.dsp.exec_cmd("swaylock"))                          -- 锁屏
hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())                                       -- 伪平铺模式
hl.bind(mainMod .. " + S", hl.dsp.layout("togglesplit"))                                 -- 切换分屏
hl.bind(mainMod .. " + return", hl.dsp.window.fullscreen())                              -- 切换当前聚焦窗口全屏
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized" }))             -- 切换为“最大化”（保留间距与顶部栏）
hl.bind("F1", hl.dsp.exec_cmd("~/.config/hypr/scripts/keybinds.sh"))                     -- 显示快捷键列表

-- 应用快捷启动
hl.bind(mainMod .. " + grave", hl.dsp.exec_cmd(terminal))                                -- 打开终端（~）
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))                                 -- 打开文件管理器
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("antigravity-ide"))                           -- 打开代码编辑器
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("obsidian"))                                  -- 打开笔记应用

------------------------------------------------
-- 控制操作
------------------------------------------------
-- 重复按键会切换/关闭启动器
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("pkill rofi || rofi -show drun"))         -- 启动应用
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("pkill rofi || rofi -show filebrowser"))      -- 浏览文件
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("pkill rofi || rofi -show run"))              -- 运行命令

-- 音量/媒体控制
-- hl.bind("F10", hl.dsp.exec_cmd("~/.config/hypr/scripts/volumecontrol.sh -o m"))         -- 切换输出静音
-- hl.bind("F11", hl.dsp.exec_cmd("~/.config/hypr/scripts/volumecontrol.sh -o d"))         -- 降低音量
-- hl.bind("F12", hl.dsp.exec_cmd("~/.config/hypr/scripts/volumecontrol.sh -o i"))         -- 提高音量
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))           -- 切换输出静音
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"))      -- 切换麦克风静音
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"))  -- 提高音量
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"))       -- 降低音量
hl.bind(mainMod .. " + XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 10%-"))      -- 快速降低音量
hl.bind(mainMod .. " + XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 10%+")) -- 快速提高音量
hl.bind(mainMod .. " + ALT + XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))  -- 切换输出静音
hl.bind(mainMod .. " + ALT + XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"))  -- 切换输出静音
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"))   -- 播放/暂停
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"))  -- 播放/暂停
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"))         -- 下一首
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"))     -- 上一首

-- 截图
hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -z -m window -o ~/tmp/screenshot"))   -- 截取当前窗口
hl.bind("ALT + PRINT", hl.dsp.exec_cmd("hyprshot -z -m region -o ~/tmp/screenshot")) -- 框选截图
hl.bind("ALT + A", hl.dsp.exec_cmd("hyprshot -z -m region -o ~/tmp/screenshot"))      -- 框选截图

-- 取色器
hl.bind(mainMod .. " + ALT + P", hl.dsp.exec_cmd("hyprpicker")) -- 取色

------------------------------------------------
-- 执行自定义脚本
------------------------------------------------
hl.bind(mainMod .. " + G", hl.dsp.exec_cmd("~/.config/hypr/scripts/gamemode.sh")) -- 游戏模式：关闭特效

------------------------------------------------
-- 窗口操作
------------------------------------------------
-- 使用徽标键+方向键切换焦点
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))   -- 向左移动焦点
hl.bind(mainMod .. " + H",     hl.dsp.focus({ direction = "left" }))   -- 向左移动焦点
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))  -- 向右移动焦点
hl.bind(mainMod .. " + L",     hl.dsp.focus({ direction = "right" }))  -- 向右移动焦点
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))     -- 向上移动焦点
hl.bind(mainMod .. " + K",     hl.dsp.focus({ direction = "up" }))     -- 向上移动焦点
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))   -- 向下移动焦点
hl.bind(mainMod .. " + J",     hl.dsp.focus({ direction = "down" }))   -- 向下移动焦点

-- 调整窗口大小
hl.bind(mainMod .. " + CONTROL + right", hl.dsp.window.resize({ x = 50,  y = 0,   relative = true })) -- 增大宽度
hl.bind(mainMod .. " + CONTROL + H",     hl.dsp.window.resize({ x = 50,  y = 0,   relative = true })) -- 增大宽度
hl.bind(mainMod .. " + CONTROL + left",  hl.dsp.window.resize({ x = -50, y = 0,   relative = true })) -- 减小宽度
hl.bind(mainMod .. " + CONTROL + L",     hl.dsp.window.resize({ x = -50, y = 0,   relative = true })) -- 减小宽度
hl.bind(mainMod .. " + CONTROL + up",    hl.dsp.window.resize({ x = 0,   y = -50, relative = true })) -- 减小高度
hl.bind(mainMod .. " + CONTROL + K",     hl.dsp.window.resize({ x = 0,   y = -50, relative = true })) -- 减小高度
hl.bind(mainMod .. " + CONTROL + down",  hl.dsp.window.resize({ x = 0,   y = 50,  relative = true })) -- 增大高度
hl.bind(mainMod .. " + CONTROL + J",     hl.dsp.window.resize({ x = 0,   y = 50,  relative = true })) -- 增大高度

-- 使用徽标键+上档键+方向键移动窗口
hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))  -- 将窗口向左移动
hl.bind(mainMod .. " + SHIFT + H",     hl.dsp.window.move({ direction = "left" }))  -- 将窗口向左移动
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" })) -- 将窗口向右移动
hl.bind(mainMod .. " + SHIFT + L",     hl.dsp.window.move({ direction = "right" })) -- 将窗口向右移动
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))    -- 将窗口向上移动
hl.bind(mainMod .. " + SHIFT + K",     hl.dsp.window.move({ direction = "up" }))    -- 将窗口向上移动
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))  -- 将窗口向下移动
hl.bind(mainMod .. " + SHIFT + J",     hl.dsp.window.move({ direction = "down" }))  -- 将窗口向下移动

-- 使用徽标键+鼠标拖拽移动/缩放窗口（左键移动，右键缩放）
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true }) -- 按住左键拖动移动窗口
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true }) -- 按住右键拖动缩放窗口

------------------------------------------------
-- 工作区操作
------------------------------------------------
-- 使用徽标键+[0-9] 切换工作区
for i = 1, 10 do
    local key = i % 10 -- 10 对应 0
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
end
hl.bind(mainMod .. " + Q", hl.dsp.focus({ workspace = 11 })) -- 切换到工作区 11
hl.bind(mainMod .. " + A", hl.dsp.focus({ workspace = 12 })) -- 切换到工作区 12
hl.bind(mainMod .. " + Z", hl.dsp.focus({ workspace = 13 })) -- 切换到工作区 13

for i = 1, 5 do
    hl.bind(mainMod .. " + CTRL + " .. i, hl.dsp.focus({ workspace = 20 + i })) -- 切换到工作区 2x
end

-- 使用徽标键+上档键+[0-9] 将当前窗口移动到工作区
for i = 1, 10 do
    local key = i % 10 -- 10 对应 0
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
hl.bind(mainMod .. " + SHIFT + Q", hl.dsp.window.move({ workspace = 11 })) -- 将窗口移动到工作区 11
hl.bind(mainMod .. " + SHIFT + A", hl.dsp.window.move({ workspace = 12 })) -- 将窗口移动到工作区 12
hl.bind(mainMod .. " + SHIFT + Z", hl.dsp.window.move({ workspace = 13 })) -- 将窗口移动到工作区 13

for i = 1, 5 do
    hl.bind(mainMod .. " + CTRL + SHIFT + " .. i, hl.dsp.window.move({ workspace = 20 + i })) -- 移动到工作区 2x
end

-- 使用徽标键+替代键+[0-9] 静默移动窗口到工作区
for i = 1, 10 do
    local key = i % 10 -- 10 对应 0
    hl.bind(mainMod .. " + ALT + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end
hl.bind(mainMod .. " + ALT + Q", hl.dsp.window.move({ workspace = 11, follow = false })) -- 静默移动到工作区 11
hl.bind(mainMod .. " + ALT + A", hl.dsp.window.move({ workspace = 12, follow = false })) -- 静默移动到工作区 12
hl.bind(mainMod .. " + ALT + Z", hl.dsp.window.move({ workspace = 13, follow = false })) -- 静默移动到工作区 13

-- 特殊工作区（临时区）
hl.bind(mainMod .. " + ALT + S", hl.dsp.window.move({ workspace = "special", follow = false })) -- 将窗口移动到临时区
hl.bind(mainMod .. " + CONTROL + S", hl.dsp.workspace.toggle_special(""))                       -- 切换临时区显示

-- 工作区导航（键盘/鼠标）
hl.bind(mainMod .. " + ALT + right", hl.dsp.focus({ workspace = "e+1" })) -- 下一个工作区
hl.bind(mainMod .. " + ALT + left",  hl.dsp.focus({ workspace = "e-1" })) -- 上一个工作区

hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e+1" })) -- 下一个工作区
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e-1" })) -- 上一个工作区

-- 工作区切换器脚本
hl.bind(mainMod .. " + TAB", hl.dsp.exec_cmd("rofi -show window -show-icons")) -- 切换窗口（列表）
