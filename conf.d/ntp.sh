#!/usr/bin/env bash

# NTP授时服务
if [ ! -f /etc/systemd/timesyncd.conf.d/local.conf ]; then
  sudo mkdir /etc/systemd/timesyncd.conf.d/
  echo '[Time]
NTP=ntp.ntsc.ac.cn cn.ntp.org.cn ntp.ntsc.ac.cn
FallbackNTP=ntp.aliyun.com time1.cloud.tencent.com time2.cloud.tencent.com time3.cloud.tencent.com time4.cloud.tencent.com time5.cloud.tencent.com' \
  | sudo tee /etc/systemd/timesyncd.conf.d/local.conf
fi
sudo systemctl enable systemd-timesyncd.service