#!/usr/bin/env bash

# archlinuxcn 镜像源配置 (幂等执行: 已配置则自动跳过)
if ! grep -q '^\s*\[archlinuxcn\]' /etc/pacman.conf 2>/dev/null; then
  echo "Adding [archlinuxcn] repository to /etc/pacman.conf..."
  cat <<'EOF' | sudo tee -a /etc/pacman.conf >/dev/null

[archlinuxcn]
Server = https://mirrors.ustc.edu.cn/archlinuxcn/$arch
EOF
  sudo pacman -Sy --noconfirm
  if ! sudo pacman -S --noconfirm --needed archlinuxcn-keyring 2>/dev/null; then
    echo "Notice: Standard keyring install failed, attempting direct pkg installation..."
    sudo pacman -U --noconfirm "https://mirrors.ustc.edu.cn/archlinuxcn/x86_64/archlinuxcn-keyring-latest-any.pkg.tar.zst" 2>/dev/null || true
  fi
fi
