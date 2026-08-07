#!/usr/bin/env bash

# 为 SSD 启用定期 TRIM
sudo systemctl enable --now fstrim.timer
