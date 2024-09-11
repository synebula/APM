#!/usr/bin/env bash

# Archlinuxcn源
if ! is_configured 'archlinuxcn' /etc/pacman.conf; then
  echo '[archlinuxcn]
Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch' \
  | sudo tee -a /etc/pacman.conf
  sudo pacman -Sy && sudo pacman -S --noconfirm archlinuxcn-keyring
fi