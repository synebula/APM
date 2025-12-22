#!/usr/bin/env bash

user=${USER:-$(whoami)}

sudo pacman -S --noconfirm --needed docker docker-compose

if [ ! -d /etc/docker/ ]; then
  sudo mkdir -p /etc/docker/
fi

# 国内加速都关停
if [ ! -f /etc/docker/daemon.json ] || [ -z "`cat /etc/docker/daemon.json | grep registry-mirrors`" ]; then
echo '{
  "experimental": true,
  "fixed-cidr-v6": "fd00::/80",
  "group": "docker",
  "hosts": [
    "fd://"
  ],
  "ip6tables": true,
  "ipv6": true,
  "live-restore": false,
  "log-driver": "json-file",
  "log-opts": {
    "max-file": "3",
    "max-size": "10m"
  },
  "registry-mirrors": [
    "https://dockercf.jsdelivr.fyi"
  ],
  "userland-proxy": false
}' | sudo tee /etc/docker/daemon.json
fi

if [ ! -f /etc/systemd/system/docker.service.d/proxy.conf ]; then
sudo mkdir -p /etc/systemd/system/docker.service.d/
echo '
[Service]
Environment="HTTP_PROXY=http://10.7.43.30:1081"
Environment="HTTPS_PROXY=http://10.7.43.30:1081"
Environment="NO_PROXY=hub-mirror.c.163.com,mirror.baidubce.com,dockerproxy.com,ccr.ccs.tencentyun.com"
' | sudo tee /etc/systemd/system/docker.service.d/proxy.conf > /dev/null
fi

sudo usermod -aG docker "$user"
sudo systemctl daemon-reload
