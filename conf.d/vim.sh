#!/usr/bin/env bash

# 配置 vim：启用行号（兼容 sudo 执行: 写入真实用户家目录而非 $HOME）
target_user="${user:-${SUDO_USER:-${LOGNAME:-$(whoami)}}}"
user_home="$(getent passwd "$target_user" | cut -d: -f6)"

vimrc="$user_home/.vimrc"
if [ ! -f "$vimrc" ] || ! is_configured 'set number' "$vimrc"; then
  echo 'set number' >>"$vimrc"
fi
