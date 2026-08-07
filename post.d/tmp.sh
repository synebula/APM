#!/usr/bin/env bash

# 判断文件中是否包含指定关键字（固定字符串匹配, 幂等检查用）
is_configured() {
  local keyword="$1" file="$2"
  [ -f "$file" ] || return 1
  grep -qF -- "$keyword" "$file"
}

target_user="${user:-${SUDO_USER:-${LOGNAME:-$(whoami)}}}"
user_home="$(getent passwd "$target_user" | cut -d: -f6)"

if [ ! -d "$user_home/tmp" ]; then
  mkdir -p "$user_home/tmp"
fi
# Configure home temp directory
if ! is_configured "$user_home/tmp" /etc/fstab; then
  echo "
# Home temp directory
tmpfs       $user_home/tmp    tmpfs      defaults,size=16g    0  0
" | sudo tee -a /etc/fstab > /dev/null
fi
