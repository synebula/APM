#!/usr/bin/env bash
path=$(dirname $0)

# 执行系统设置
source ${path}/setup.sh

## 比较软件包到异同进行安装或卸载

# 合并软件列表
pkgs=$(sed 's/#.*$//g' ${path}/packages.pkg)
for pkg in $(ls $path/packages.d | grep .*.pkg); do
  pkgs="$pkgs $(sed 's/#.*$//g' ${path}/packages.d/$pkg)"
done

sudo pacman -Sy

# 第一次执行直接生产lock文件
if [ ! -e ${path}/.packages.lock ]; then
  echo -n $pkgs | tr ' ' '\n' | sort >${path}/.packages.lock
  yay -S --noconfirm --needed $pkgs
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
    sudo pacman --noconfirm -Rns $(echo $removed)
  fi
  mv ${path}/.packages.tmp ${path}/.packages.lock
fi
