#!/usr/bin/env bash

# 获取窗口列表，格式为 "ADDRESS    [Workspace] Class: Title"
# 使用 jq 解析 hyprctl clients -j 的 JSON 输出
# select(.workspace.id != -1) 过滤掉特殊工作区（如概览）的窗口
WINDOWS_LIST=$(hyprctl clients -j | jq -r '.[] | select(.workspace.id != -1) | "\(.address)\t[\(.workspace.name)] \(.class): \(.title)"')

# 如果没有窗口，显示提示并退出
if [ -z "$WINDOWS_LIST" ]; then
    rofi -e "No open windows found."
    exit 1
fi

# 使用 Rofi 显示窗口列表，允许用户选择
# -dmenu: dmenu 模式
# -i: 不区分大小写搜索
# -p: 提示符文本
# -markup-rows: (可选) 如果你想在列表中使用 Pango 标记
# -format 's': 输出选择的完整行
CHOSEN_WINDOW_LINE=$(echo -e "$WINDOWS_LIST" | rofi -dmenu -i -p "󰖯 Switch Window" -format 's')
# 你可以使用其他图标，例如  或 Window:

# 如果用户取消了选择 (Rofi 返回空)，则退出
if [ -z "$CHOSEN_WINDOW_LINE" ]; then
    exit 0
fi

# 从选择的行中提取窗口地址 (它是第一个字段，以制表符分隔)
CHOSEN_ADDRESS=$(echo "$CHOSEN_WINDOW_LINE" | awk -F'\t' '{print $1}')

# 使用 hyprctl 切换到选定的窗口
hyprctl dispatch focuswindow address:"$CHOSEN_ADDRESS"

exit 0
