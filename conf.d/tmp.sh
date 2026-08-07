#!/usr/bin/env bash

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
