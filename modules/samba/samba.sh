#!/usr/bin/env bash

user=`whoami`
path=`dirname $0`

sudo pacman -S --noconfirm --needed samba

sudo cp ${path}/smb.conf /etc/samba/smb.conf
sudo systemctl enable --now smb

# 两次确认密码
echo -e "0000\n0000" | sudo smbpasswd -a $user -s