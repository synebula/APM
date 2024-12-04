#!/usr/bin/env bash

yay -S --needed xone-dkms-git cabextract
# 下载驱动固件
sudo bash /usr/lib/xone/firmware.sh
# Or
# yay -S --needed xone-dongle-firmware