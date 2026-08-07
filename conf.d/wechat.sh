#!/usr/bin/env bash

target_user="${user:-${SUDO_USER:-${LOGNAME:-$(whoami)}}}"
user_home="$(getent passwd "$target_user" | cut -d: -f6)"

if [ -f /usr/lib/wechat-universal/start.sh ] && [ ! -f "$user_home/.local/share/applications/wechat-universal.desktop" ]; then
  mkdir -p "$user_home/.local/share/applications"
  sed "s|^Exec=|Exec=env WECHAT_DATA_DIR=$user_home/.local/WeChat |" /usr/share/applications/wechat-universal.desktop \
    >"$user_home/.local/share/applications/wechat-universal.desktop"
fi

if ! is_configured "zerociqher_516a" /etc/fstab; then
  echo "
# wechat temp directory
tmpfs       $user_home/.local/WeChat/xwechat_files/zerociqher_516a/temp/ImageUtils    tmpfs      defaults,size=4g    0  0
tmpfs       $user_home/.local/WeChat/xwechat_files/zerociqher_516a/temp/InputTemp    tmpfs      defaults,size=4g    0  0
" | sudo tee -a /etc/fstab > /dev/null
fi
