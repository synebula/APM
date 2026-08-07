#!/usr/bin/env bash

# 设置固定 IP（需安装 nmcli）
if ! command -v nmcli >/dev/null 2>&1; then
  return 0 2>/dev/null || exit 0
fi

iface="${APM_IFACE:-eno1}"
connection=$(nmcli -g GENERAL.CONNECTION d show "$iface" 2>/dev/null | sed 's/^[[:space:]]*//')
if [ -z "$connection" ]; then
  return 0 2>/dev/null || exit 0
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
