#!/usr/bin/env bash
# 切换 Hyprland 配置格式 (lua <-> conf)

set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BAK="$DIR/bak"
MODULES=(hyprland animations keybindings monitors theme userprefs windowrules nvidia)

if [ -f "$DIR/hyprland.lua" ]; then
  from="lua"; to="conf"
else
  from="conf"; to="lua"
fi

if [[ "${1:-}" != "-y" && "${1:-}" != "--yes" ]]; then
  read -r -p "当前为 $from 格式，确认切换为 $to 格式并退出 Hyprland？[y/N] " ans
  case "$ans" in
    y|Y|yes|YES|Yes) ;;
    *) echo "已取消切换。"; exit 0 ;;
  esac
fi

mkdir -p "$BAK"
for m in "${MODULES[@]}"; do
  [ -f "$DIR/$m.$from" ] && mv -f "$DIR/$m.$from" "$BAK/"
  [ -f "$BAK/$m.$to" ]   && mv -f "$BAK/$m.$to" "$DIR/"
done

echo "已切换为 $to 格式，正在退出 Hyprland..."
pkill -x Hyprland 2>/dev/null || killall Hyprland 2>/dev/null || true
