#!/usr/bin/env bash

# 判断文件中是否包含指定关键字。
# 用法：is_configured 'keyword' file
is_configured() {
  local keyword="$1"
  local file="$2"

  if [ ! -f "$file" ]; then
    return 1
  fi

  # -F 按固定字符串匹配, 关键字含路径/正则特殊字符时不会被解释为正则
  if grep -qF -- "$keyword" "$file"; then
    return 0
  fi

  return 1
}

# 获取当前实际运行的非 root 用户（兼容 sudo 执行场景）
get_current_user() {
  echo "${SUDO_USER:-${LOGNAME:-$(whoami)}}"
}

# 判断当前用户使用的 shell 并返回 shell 配置文件路径
get_shell_config_file() {
  local target_user target_home user_shell
  target_user="$(get_current_user)"
  target_home="$(getent passwd "$target_user" | cut -d: -f6)"
  user_shell="$(getent passwd "$target_user" | cut -d: -f7)"

  case "$user_shell" in
    /bin/bash)
      echo "$target_home/.bashrc"
      ;;
    /bin/zsh)
      echo "$target_home/.zshrc"
      ;;
    /bin/fish)
      echo "$target_home/.config/fish/config.fish"
      ;;
    *)
      echo "$target_home/.bashrc"
      ;;
  esac
}

# 检查网络连通性：优先使用 curl，不可用时回退到 ping
check_network() {
  local url host

  if command -v curl >/dev/null 2>&1; then
    for url in "https://archlinux.org" "https://mirrors.ustc.edu.cn"; do
      if curl --silent --head --max-time 5 "$url" >/dev/null 2>&1; then
        return 0
      fi
    done
  elif command -v ping >/dev/null 2>&1; then
    for host in "archlinux.org" "mirrors.ustc.edu.cn"; do
      if ping -c 1 -W 5 "$host" >/dev/null 2>&1; then
        return 0
      fi
    done
  fi

  return 1
}
