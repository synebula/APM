#!/usr/bin/env bash

# 设置固定ip
connection="$(nmcli d show eno1 | grep GENERAL.CONNECTION | sed 's/GENERAL.CONNECTION://;s/^[[:space:]]*//')"
if [ ! $(nmcli --field ipv4.method c show "$connection" | awk '{print $2}') == 'manual' ]; then
  nmcli c mod "$connection" ipv4.address 10.7.43.20/24
  nmcli c mod "$connection" ipv4.gateway 10.7.43.1
  nmcli c mod "$connection" ipv4.method manual
  nmcli c mod "$connection" ipv4.dns "10.7.43.1"
fi

for c in `nmcli c | awk '{print $1}' | sed 1d`; do nmcli c mod "$c" 802-3-ethernet.wake-on-lan magic; done
