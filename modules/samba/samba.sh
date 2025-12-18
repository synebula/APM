#!/usr/bin/env bash

user=${USER:-$(whoami)}
path=$(cd "$(dirname "$0")" && pwd)

sudo pacman -S --noconfirm --needed samba

sudo cp "${path}/smb.conf" /etc/samba/smb.conf
sudo systemctl enable --now smb

# 两次确认密码
printf '0000\n0000\n' | sudo smbpasswd -a "$user" -s
