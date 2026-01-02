#!/usr/bin/env bash

if command -v fcitx5 >/dev/null 2>&1 && ! grep -q 'fcitx' /etc/environment 2>/dev/null; then
  cat <<'EOF' | sudo tee -a /etc/environment >/dev/null
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=ibus
EOF
fi

# 禁用 V 键触发快速输入
PINYIN_CONF="$HOME/.config/fcitx5/conf/pinyin.conf"
if [[ -f "$PINYIN_CONF" ]] && grep -q "VAsQuickphrase=True" "$PINYIN_CONF"; then
  pkill fcitx5 2>/dev/null || true
  sed -i 's/VAsQuickphrase=True/VAsQuickphrase=False/' "$PINYIN_CONF"
  nohup fcitx5 -d &>/dev/null &
fi
