#!/usr/bin/env bash

# 判断文件中是否包含指定关键字（固定字符串匹配, 幂等检查用）
is_configured() {
  local keyword="$1" file="$2"
  [ -f "$file" ] || return 1
  grep -qF -- "$keyword" "$file"
}

# 配置 vim：启用行号（兼容 sudo 执行: 写入真实用户家目录而非 $HOME）
target_user="${user:-${SUDO_USER:-${LOGNAME:-$(whoami)}}}"
user_home="$(getent passwd "$target_user" | cut -d: -f6)"

vimrc="$user_home/.vimrc"
if [ ! -f "$vimrc" ] || ! is_configured 'set number' "$vimrc"; then
  echo 'set number' >>"$vimrc"
fi
