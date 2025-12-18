#!/usr/bin/env bash

## 1. 基础设置

set -euo pipefail
IFS=$'\n\t'

user=$(whoami)
# 设置脚本所在目录
path=$(cd "$(dirname "$0")" && pwd)

# 设置默认的软件包管理器（可通过环境变量 APM_BACKEND 覆盖）
apm="${apm:-yay}"
APM_BACKEND="${APM_BACKEND:-$apm}"

# 导入依赖方法
. "$path/func.sh"

## 2. 判断是否联网
if check_network; then
  echo -e "\033[32mNetwork Connected! \033[0m"
else
  echo -e "\033[31mNetwork Not Connected! \033[0m"
  exit 1
fi

## 3. 配置 pacman 源和包管理后端

# 3.1 Archlinuxcn 源
if ! is_configured 'archlinuxcn' /etc/pacman.conf; then
  echo '[archlinuxcn]
  Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch' \
  | sudo tee -a /etc/pacman.conf > /dev/null
  sudo pacman -Sy && sudo pacman -S --noconfirm archlinuxcn-keyring
fi

# 3.2 如果不是 pacman 管理包，并且没有安装则安装该包管理器
if ! command -v "$APM_BACKEND" >/dev/null 2>&1; then
  if [ "$APM_BACKEND" != "pacman" ]; then
    sudo pacman -S --noconfirm "$APM_BACKEND"
  fi
fi

# 3.3 封装包管理后端命令，处理 pacman 与 AUR helper 的差异
apm_sync() {
  if [ "$APM_BACKEND" = "pacman" ]; then
    sudo pacman -Sy
  else
    "$APM_BACKEND" -Sy
  fi
}

apm_install() {
  if [ "$APM_BACKEND" = "pacman" ]; then
    # shellcheck disable=SC2086
    sudo pacman -S --noconfirm --needed "$@"
  else
    # shellcheck disable=SC2086
    "$APM_BACKEND" -S --noconfirm --needed "$@"
  fi
}

apm_remove() {
  if [ "$APM_BACKEND" = "pacman" ]; then
    # shellcheck disable=SC2086
    sudo pacman --noconfirm -Rns "$@"
  else
    # shellcheck disable=SC2086
    "$APM_BACKEND" --noconfirm -Rns "$@"
  fi
}

## 4. 比较软件包的异同进行安装或卸载

lock_file="${path}/.packages.lock"
desired_file="${path}/.packages.desired"

# 合并软件列表，每行一个包名，去重排序
parse_all_packages "${path}/packages.ini" "${path}"/packages.d/*.ini \
  | sort -u >"$desired_file"

# 同步软件包数据库
apm_sync

if [ ! -s "$lock_file" ]; then
  # 第一次执行：全量安装并生成 lock 文件
  if [ -s "$desired_file" ]; then
    # shellcheck disable=SC2046
    apm_install $(cat "$desired_file")
  fi
  cp "$desired_file" "$lock_file"
else
  # 后续执行：比对 lock 文件，找出新增和移除的软件包
  added=$(comm -13 "$lock_file" "$desired_file" | xargs || true)
  removed=$(comm -23 "$lock_file" "$desired_file" | xargs || true)

  # 先删除再安装，避免包冲突
  if [ -n "${removed:-}" ]; then
    # shellcheck disable=SC2086
    apm_remove $removed
  fi

  if [ -n "${added:-}" ]; then
    # shellcheck disable=SC2086
    apm_install $added
  fi

  cp "$desired_file" "$lock_file"
fi

## 5. 执行 conf.d 中的配置脚本
while IFS= read -r -d '' script; do
  # 每个配置脚本都设计为可重复执行
  # shellcheck disable=SC1090
  source "$script"
done < <(find "${path}/conf.d/" -type f -name "*.sh" -print0)
