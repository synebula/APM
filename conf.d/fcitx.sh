#!/usr/bin/env bash

lines=$(cat /etc/environment | grep fcitx)
which fcitx5 >/dev/null 2>&1
if [ $? -eq 0 ] && [ ! -n "$lines" ]; then

  echo 'GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=ibus' |
    sudo tee -a /etc/environment >/dev/null

fi
