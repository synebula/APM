#!/usr/bin/env bash

# 系统已有 swap 条目（如 installer.sh 创建的 /swapfile）时不再重复创建
if awk '$3 == "swap" { found = 1 } END { exit !found }' /etc/fstab 2>/dev/null; then
  return 0 2>/dev/null || exit 0
fi

if [ ! -f /var/.swapfile ]; then
  fs_type=$(stat -f -c %T /var 2>/dev/null || echo "unknown")
  if [ "$fs_type" = "btrfs" ]; then
    sudo truncate -s 0 /var/.swapfile
    sudo chattr +C /var/.swapfile 2>/dev/null || true
    sudo fallocate -l 32G /var/.swapfile 2>/dev/null || sudo dd if=/dev/zero of=/var/.swapfile bs=1M count=32768 status=progress
  else
    sudo fallocate -l 32G /var/.swapfile
  fi
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
