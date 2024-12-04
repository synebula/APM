#!/usr/bin/env bash

if [ ! -f /var/.swapfile ]; then
  sudo fallocate -l 32G /var/.swapfile
  sudo chmod 600 /var/.swapfile
  sudo mkswap /var/.swapfile
  sudo swapon /var/.swapfile
fi

if ! is_configured ".swapfile" /etc/fstab; then
  echo "
# swapfile
/var/.swapfile    none    swap    sw    0   0
" | sudo tee -a /etc/fstab > /dev/null
fi
