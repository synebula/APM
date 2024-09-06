#!/usr/bin/env bash
path=$(dirname $0)

if ping -c 1 -W 5 baidu.com 1>/dev/null 2>&1; then
    echo "Network Connected!"
else
    echo "Network Not Connected!"
    exit 0
fi

# 执行系统设置
source ${path}/setup.sh

## 比较软件包到异同进行安装或卸载

# 合并软件列表
pkgs=$(sed 's/#.*$//g' ${path}/packages.ini)
for pkg in $(ls $path/packages.d | grep .*.ini); do
  pkgs="$pkgs $(sed 's/#.*$//g' ${path}/packages.d/$pkg)"
done

sudo pacman -Sy

# 第一次执行直接生产lock文件
# 需要处理 AUR 包，需要更换 sudo pacman 命令到 yay
if [ ! -e ${path}/.packages.lock ]; then
  yay -S --noconfirm --needed $pkgs
  echo -n $pkgs | tr ' ' '\n' | sort >${path}/.packages.lock
else
  # 比对lock文件，找出修改的软件包
  echo -n $pkgs | tr ' ' '\n' | sort >${path}/.packages.tmp
  added=$(diff -u ${path}/.packages.lock ${path}/.packages.tmp | grep "^+[[:alpha:]].*" | sed s/+//)
  removed=$(diff -u ${path}/.packages.lock ${path}/.packages.tmp | grep "^-[[:alpha:]].*" | sed s/-//)

  set -e
  if [ -n "$(echo $added)" ]; then
    yay -S --noconfirm --needed $(echo $added)
  fi
  if [ -n "$removed" ]; then
    yay --noconfirm -Rns $(echo $removed)
  fi
  mv ${path}/.packages.tmp ${path}/.packages.lock
fi
