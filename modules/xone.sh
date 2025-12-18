#!/usr/bin/env bash

if ! command -v yay >/dev/null 2>&1; then
  echo "AUR helper 'yay' is required for xone module." >&2
  exit 1
fi

yay -S --needed xone-dkms-git cabextract
# 下载驱动固件
sudo bash /usr/lib/xone/firmware.sh
# Or
# yay -S --needed xone-dongle-firmware
