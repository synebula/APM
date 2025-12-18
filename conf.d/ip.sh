#!/usr/bin/env bash

# 设置固定 IP（需存在 eno1 且安装 nmcli）
if ! command -v nmcli >/dev/null 2>&1; then
  exit 0
fi

connection=$(nmcli -g GENERAL.CONNECTION d show eno1 2>/dev/null | sed 's/^[[:space:]]*//')
if [ -z "$connection" ]; then
  # 未找到 eno1，对当前环境忽略
  exit 0
fi

current_method=$(nmcli -g ipv4.method c show "$connection" 2>/dev/null | sed 's/^[[:space:]]*//')
if [ "$current_method" != 'manual' ]; then
  nmcli c mod "$connection" ipv4.address 10.7.43.20/24
  nmcli c mod "$connection" ipv4.gateway 10.7.43.1
  nmcli c mod "$connection" ipv4.method manual
  nmcli c mod "$connection" ipv4.dns "10.7.43.1"
fi

nmcli -t -f NAME c 2>/dev/null | sed '1d' | while IFS= read -r c; do
  nmcli c mod "$c" 802-3-ethernet.wake-on-lan magic
done
