#!/usr/bin/env bash

user=`whoami`
path=`dirname $0`

# 判断文件是否存在内容。用法：is_configured 'keyword' file;
is_configured() {
  lines=$(cat $2 | grep $1)
  if [ -n "$lines" ]; then
    return 0
  fi
  return 1
}

# NTP授时服务
if [ ! -f /etc/systemd/timesyncd.conf.d/local.conf ]; then
sudo mkdir /etc/systemd/timesyncd.conf.d/
echo '[Time]
NTP=ntp.ntsc.ac.cn cn.ntp.org.cn ntp.ntsc.ac.cn
FallbackNTP=ntp.aliyun.com time1.cloud.tencent.com time2.cloud.tencent.com time3.cloud.tencent.com time4.cloud.tencent.com time5.cloud.tencent.com
' | sudo tee /etc/systemd/timesyncd.conf.d/local.conf
fi

# archlinuxcn源
if ! is_configured 'archlinuxcn' /etc/pacman.conf; then
  echo '[archlinuxcn]
  Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch' \
  | sudo tee -a /etc/pacman.conf
  sudo pacman -Sy && sudo pacman -S archlinuxcn-keyring
fi

# install aur helper
if ! command -v yay >/dev/null 2>&1; then 
  git clone https://aur.archlinux.org/yay-git.git /tmp/yay
  cd /tmp/yay
  makepkg -si
  cd -
fi

# configure home temp directory
if ! is_configured "/home/$user/tmp" /etc/fstab; then
  echo "# Home temp directory
tmpfs       /home/$user/tmp    tmpfs      defaults,size=16g    0  0" | sudo tee -a /etc/fstab
fi