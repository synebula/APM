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
# 兼容 sudo 执行: 配置路径取真实用户家目录; 后台进程关闭 fd 9 避免继承 apm 的 flock 锁
target_user="${user:-${SUDO_USER:-${LOGNAME:-$(whoami)}}}"
user_home="$(getent passwd "$target_user" | cut -d: -f6)"

PINYIN_CONF="$user_home/.config/fcitx5/conf/pinyin.conf"
if [[ -f "$PINYIN_CONF" ]] && grep -q "VAsQuickphrase=True" "$PINYIN_CONF"; then
  pkill fcitx5 2>/dev/null || true
  sed -i 's/VAsQuickphrase=True/VAsQuickphrase=False/' "$PINYIN_CONF"
  nohup fcitx5 -d &>/dev/null 9>&- &
fi
