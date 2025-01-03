#!/usr/bin/env bash

# 启用alias
shopt -s expand_aliases

## 1. 设置变量
user=$(whoami)
# 设置脚本所在目录
path=$(cd "$(dirname $0)";pwd)
# 设置默认的软件包管理器
apm="yay"
alias apm=$apm

# 导入依赖方法
. $path/func.sh

## 2. 判断是否联网
if ping -c 1 -W 5 bilibili.com 1>/dev/null 2>&1; then
  echo -e "\033[32mNetwork Connected! \033[0m"
else
  echo -e "\033[31mNetwork Not Connected! \033[0m"
  exit 0
fi


## 3. 执行 conf.d 中的脚本文件

# 3.1 Archlinuxcn源
if ! is_configured 'archlinuxcn' /etc/pacman.conf; then
  echo '[archlinuxcn]
  Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch' \
  | sudo tee -a /etc/pacman.conf > /dev/null
  sudo pacman -Sy && sudo pacman -S --noconfirm archlinuxcn-keyring
fi

# 3.2 如果不是pacman管理包，并且没有安装则安装该包管理器
which $apm >/dev/null 2>&1
exist=$?
if [ -z "$(echo $apm | grep 'pacman')" ] && [ $exist -ne 0 ]; then
  sudo pacman -S --noconfirm $apm
fi

## 4. 比较软件包到异同进行安装或卸载
# 合并软件列表
comment='s/#.*$//g;s/\;.*$//g;s/\[.*$//g'
pkgs=$(sed $comment ${path}/packages.ini)
for pkg in $(find ${path}/packages.d/ -type f -name "*.ini"); do
  pkgs="$pkgs $(sed $comment $pkg)"
done

# 设置遇到错误不继续执行
set -e
# 第一次执行直接生产lock文件
apm -Sy
if [ ! -e ${path}/.packages.lock ]; then
  apm -S --noconfirm --needed $pkgs
  echo -n $pkgs | tr ' ' '\n' | sort >${path}/.packages.lock # 写入lock文件，提供下次安装时比较异同
else
  # 后续执行比对lock文件，找出修改的软件包
  echo -n $pkgs | tr ' ' '\n' | sort >${path}/.packages.tmp
  added=$(diff -u ${path}/.packages.lock ${path}/.packages.tmp | grep "^+[[:alpha:]].*" | sed s/+//)
  removed=$(diff -u ${path}/.packages.lock ${path}/.packages.tmp | grep "^-[[:alpha:]].*" | sed s/-//)
  
  # 先删除再安装，避免包冲突
  if [ -n "$removed" ]; then
    apm --noconfirm -Rns $(echo $removed)
  fi

  if [ -n "$(echo $added)" ]; then
    apm -S --noconfirm --needed $(echo $added)
  fi
  mv "${path}/.packages.tmp" "${path}/.packages.lock"
fi

# 5. Exec config script
for script in $(find ${path}/conf.d/ -type f -name "*.sh"); do
  source "$script"
done