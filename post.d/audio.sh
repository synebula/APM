#!/usr/bin/env bash

# 禁用音频闲置后休眠的特性，避免闲置后声音延迟出声
# wireplumber 0.5.x: node.features.suspend-node 键不存在, 需通过禁用 hooks.node.suspend 实现
target_user="${user:-${SUDO_USER:-${LOGNAME:-$(whoami)}}}"
user_home="$(getent passwd "$target_user" | cut -d: -f6)"

if ! systemctl --user is-active --quiet wireplumber.service 2>/dev/null; then
  return 0 2>/dev/null || exit 0
fi

wireplumber_conf="$user_home/.config/wireplumber/wireplumber.conf.d/51-disable-suspend.conf"
# 旧版写入的 node.features 配置在 0.5.x 无效, 命中则一并迁移
if [ ! -f "$wireplumber_conf" ] || grep -q 'node.features' "$wireplumber_conf" 2>/dev/null; then
  mkdir -p "$(dirname "$wireplumber_conf")"
  cat >"$wireplumber_conf" <<'EOF'
wireplumber.profiles = {
  main = {
    hooks.node.suspend = disabled,
  },
}
EOF
  systemctl --user restart wireplumber.service
fi
