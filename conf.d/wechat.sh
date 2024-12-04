#!/usr/bin/env bash

if [ -f /usr/lib/wechat-universal/start.sh ] && [ ! -f /home/$user/.local/share/applications/wechat-universal.desktop ]; then
  sed "s|^Exec=|Exec=env WECHAT_DATA_DIR=/home/$user/.local/WeChat |" /usr/share/applications/wechat-universal.desktop |
    >/home/$user/.local/share/applications/wechat-universal.desktop
fi

if ! is_configured "zerociqher_516a" /etc/fstab; then
  echo "
# wechat temp directory
tmpfs       /home/$user/.local/WeChat/xwechat_files/zerociqher_516a/temp/ImageUtils    tmpfs      defaults,size=4g    0  0
tmpfs       /home/$user/.local/WeChat/xwechat_files/zerociqher_516a/temp/InputTemp    tmpfs      defaults,size=4g    0  0
" | sudo tee -a /etc/fstab > /dev/null
fi
