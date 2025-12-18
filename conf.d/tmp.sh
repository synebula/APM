#!/usr/bin/env bash

if [ ! -d "/home/$user/tmp" ]; then
  mkdir -p "/home/$user/tmp"
fi
# Configure home temp directory
if ! is_configured "/home/$user/tmp" /etc/fstab; then
  echo "
# Home temp directory
tmpfs       /home/$user/tmp    tmpfs      defaults,size=16g    0  0
" | sudo tee -a /etc/fstab > /dev/null
fi
