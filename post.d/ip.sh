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

# 跳过 bridge/bond 从属连接: port 连接不允许配置 IP
ctype=$(nmcli -g connection.type c show "$connection" 2>/dev/null | sed 's/^[[:space:]]*//')
cmaster=$(nmcli -g connection.master c show "$connection" 2>/dev/null | sed 's/^[[:space:]]*//')
if [ "$ctype" = '802-3-ethernet' ] && [ -z "$cmaster" ]; then
  current_method=$(nmcli -g ipv4.method c show "$connection" 2>/dev/null | sed 's/^[[:space:]]*//')
  if [ "$current_method" != 'manual' ]; then
    nmcli c mod "$connection" ipv4.address 10.7.43.20/24
    nmcli c mod "$connection" ipv4.gateway 10.7.43.1
    nmcli c mod "$connection" ipv4.method manual
    nmcli c mod "$connection" ipv4.dns "10.7.43.1"
  fi
fi

# 仅对以太网类型连接设置 WOL, 跳过 loopback/bridge/蓝牙等
nmcli -t -f NAME,TYPE c 2>/dev/null | sed '1d' | while IFS=':' read -r c t; do
  [ "$t" = '802-3-ethernet' ] || continue
  nmcli c mod "$c" 802-3-ethernet.wake-on-lan magic
done
