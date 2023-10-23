#!/usr/bin/env bash

sudo pacman -S --noconfirm --needed fcitx5-im fcitx5-chinese-addons catppuccin-fcitx5-git

lines=$(cat /etc/environment | grep fcitx)
if [ ! -n "$lines" ]; then

echo 'GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=ibus' \
| sudo tee -a /etc/environment

fi

