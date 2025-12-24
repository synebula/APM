#!/usr/bin/env sh
# 作用：切换 Hyprland“游戏模式”——关闭动画/阴影/模糊/gaps/圆角等以提升性能；再次运行会通过 reload 恢复配置。

set -eu

notify() {
  if command -v notify-send >/dev/null 2>&1; then
    notify-send -i 'applications-games' -a 'Hyprgame' 'Game Mode' "$1"
  fi
}

get_option_value() {
  # 兼容不同 hyprctl 输出格式，优先读取 int/float，其次读取 “-> <value>” 的末尾值
  hyprctl getoption "$1" 2>/dev/null | awk '
    /^int:/ { print $2; exit }
    /^float:/ { print $2; exit }
    /^str:/ { $1=""; sub(/^[ \t]+/, "", $0); print $0; exit }
    /->/ { print $NF; exit }
  '
}

if ! command -v hyprctl >/dev/null 2>&1; then
  echo "未找到 hyprctl，无法切换游戏模式。" >&2
  exit 1
fi

ANIM_ENABLED="$(get_option_value "animations:enabled" || true)"

case "$ANIM_ENABLED" in
  1|true|yes|on)
    # 当前动画开启 → 开启“游戏模式”（关闭特效）
    hyprctl --batch "\
      keyword animations:enabled 0;\
      keyword decoration:drop_shadow 0;\
      keyword decoration:blur:enabled 0;\
      keyword general:gaps_in 0;\
      keyword general:gaps_out 0;\
      keyword general:border_size 1;\
      keyword decoration:rounding 0"
    notify "on"
    ;;
  0|false|no|off)
    # 当前动画关闭 → 退出“游戏模式”（reload 恢复配置）
    hyprctl reload
    notify "off"
    ;;
  *)
    echo "无法解析 animations:enabled 当前值：${ANIM_ENABLED:-<empty>}" >&2
    exit 1
    ;;
esac
