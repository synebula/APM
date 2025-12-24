#!/usr/bin/env bash
# 作用：通过 rofi（启动器同款样式）列出当前窗口并显示图标，选择后切换焦点到对应窗口。

set -euo pipefail

if pgrep -x rofi >/dev/null 2>&1; then
  pkill rofi
  exit 0
fi

if ! command -v hyprctl >/dev/null 2>&1; then
  echo "未找到 hyprctl，无法获取窗口列表。" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "未找到 jq，无法解析 hyprctl 的 JSON 输出。" >&2
  exit 1
fi

if ! command -v rofi >/dev/null 2>&1; then
  echo "未找到 rofi，无法展示窗口列表。" >&2
  exit 1
fi

CLIENTS_JSON="$(hyprctl clients -j 2>/dev/null || true)"

# 过滤掉特殊工作区（如概览），并尽量只展示已映射的窗口
JQ_CLIENT_FILTER='.[] | select(.workspace.id != -1) | select((.mapped // true) == true)'

mapfile -t ADDRESSES < <(jq -r "$JQ_CLIENT_FILTER | .address" <<<"$CLIENTS_JSON")

# 如果没有窗口，显示提示并退出
if ((${#ADDRESSES[@]} == 0)); then
  rofi -e "No open windows found."
  exit 1
fi

# 使用 rofi 展示窗口列表（不显示 address），用索引回查 address
CHOSEN_INDEX="$(
  jq -r '
    def esc: gsub("&";"&amp;") | gsub("<";"&lt;") | gsub(">";"&gt;");
    '"$JQ_CLIENT_FILTER"' |
    (.workspace.name // "") as $ws |
    (.initialClass // .class // .appId // "unknown") as $ref |
    (.title // .initialTitle // "") as $title |
    (if $ws != "" then "<span size=\"small\">[" + ($ws|esc) + "]</span> " else "" end) as $ws_prefix |
    (if $title != "" then ($title|esc) else "-" end) as $title_text |
    ($ws_prefix + "<b>" + ($ref|esc) + "</b> — " + $title_text)
    + "\u0000icon\u001f" + $ref
  ' <<<"$CLIENTS_JSON" \
    | rofi -dmenu -i -p "󰖯 Switch Window" -markup-rows -show-icons -no-custom -format i
)"

# 如果用户取消了选择 (Rofi 返回空)，则退出
if [[ -z "$CHOSEN_INDEX" ]]; then
  exit 0
fi

if ! [[ "$CHOSEN_INDEX" =~ ^[0-9]+$ ]]; then
  echo "无效选择：$CHOSEN_INDEX" >&2
  exit 1
fi

CHOSEN_ADDRESS="${ADDRESSES[$CHOSEN_INDEX]:-}"
if [[ -z "$CHOSEN_ADDRESS" ]]; then
  echo "未找到对应窗口 address（index=$CHOSEN_INDEX）。" >&2
  exit 1
fi

hyprctl dispatch focuswindow address:"$CHOSEN_ADDRESS"

exit 0
