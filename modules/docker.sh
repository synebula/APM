#!/usr/bin/env bash

user=`whoami`

sudo pacman -S --noconfirm --needed docker

if [ ! -d /etc/docker/ ]; then
  sudo mkdir /etc/docker/
fi

if [ ! -f /etc/docker/daemon.json ] || [ -z "`cat /etc/docker/daemon.json | grep registry-mirrors`" ]; then
sudo bash -c 'cat >> /etc/docker/daemon.json << EFO
{
  "registry-mirrors": [
    "https://hub-mirror.c.163.com",
    "https://mirror.baidubce.com",
    "https://dockerproxy.com",
    "https://ccr.ccs.tencentyun.com"
  ]
}
EFO'
fi

sudo usermod -aG docker $user