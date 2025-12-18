#!/usr/bin/env bash

if command -v fcitx5 >/dev/null 2>&1 && ! grep -q 'fcitx' /etc/environment 2>/dev/null; then
  cat <<'EOF' | sudo tee -a /etc/environment >/dev/null
GTK_IM_MODULE=fcitx
QT_IM_MODULE=fcitx
XMODIFIERS=@im=fcitx
SDL_IM_MODULE=fcitx
GLFW_IM_MODULE=ibus
EOF
fi
