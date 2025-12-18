#!/usr/bin/env sh

# 简单示例：从 hyprland.conf 提取非注释的 bind= 行
# 注意：这可能需要根据你的配置复杂性进行调整（例如处理逗号后的空格、多行绑定等）
grep '^bind =' ~/.config/hypr/keybindings.conf | \
sed 's/^bind = //; s/, /\t/' | \
# 可以进一步处理，比如移除 exec 后面的命令细节，只留动作描述
# sed -E 's/,(.+)/ : \1/' | # 简单替换
column -t -s $'\t' | \
env -u WAYLAND_DISPLAY rofi -dmenu -i -p "Hyprland Keybinds" -markup-rows -config ~/.config/rofi/config-keybinds.rasi
# 或者使用 wofi:
# wofi --dmenu --prompt "Hyprland Keybinds" --insensitive
