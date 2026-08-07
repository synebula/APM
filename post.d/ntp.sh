#!/usr/bin/env bash

# NTP授时服务
if systemctl status systemd-timesyncd.service >/dev/null 2>&1 && [ ! -f /etc/systemd/timesyncd.conf.d/local.conf ]; then
  sudo mkdir -p /etc/systemd/timesyncd.conf.d
  cat <<'EOF' | sudo tee /etc/systemd/timesyncd.conf.d/local.conf >/dev/null
[Time]
NTP=ntp.ntsc.ac.cn cn.ntp.org.cn ntp.ntsc.ac.cn
FallbackNTP=ntp.aliyun.com time1.cloud.tencent.com time2.cloud.tencent.com time3.cloud.tencent.com time4.cloud.tencent.com time5.cloud.tencent.com
EOF
fi
sudo systemctl enable systemd-timesyncd.service
