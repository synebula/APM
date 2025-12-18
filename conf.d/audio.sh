#!/usr/bin/env bash

# 禁用音频闲置后休眠的特性，避免闲置后声音延迟出声
systemctl --user status wireplumber.service >/dev/null
if [ $? == 0 ] && [ -f /usr/share/wireplumber/wireplumber.conf ] && [ ! -f /home/$user/.config/wireplumber/wireplumber.conf ]; then
    # 不存在配置目录则创建
    if [ ! -d /home/$user/.config/wireplumber/ ]; then mkdir -p /home/$user/.config/wireplumber/; fi
    sed -e '1!{h;N;/suspend-node.lua/{N;N;d;}};' /usr/share/wireplumber/wireplumber.conf | sed -e ':a;N;s/hooks.node.suspend\n \+//' |
        tee /home/$user/.config/wireplumber/wireplumber.conf >/dev/null
fi
systemctl --user restart wireplumber.service >/dev/null
