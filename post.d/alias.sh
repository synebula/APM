#!/usr/bin/env bash

# 自包含实现: 独立于 func.sh 与 apm 注入变量, 脚本可脱离 apm 单独运行
path=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

# 定位真实用户的 shell 配置文件（兼容 sudo 执行）
get_shell_config_file() {
  local target_user target_home user_shell
  target_user="${SUDO_USER:-${LOGNAME:-$(whoami)}}"
  target_home="$(getent passwd "$target_user" | cut -d: -f6)"
  user_shell="$(getent passwd "$target_user" | cut -d: -f7)"
  case "$user_shell" in
    /bin/bash) echo "$target_home/.bashrc" ;;
    /bin/zsh) echo "$target_home/.zshrc" ;;
    /bin/fish) echo "$target_home/.config/fish/config.fish" ;;
    *) echo "$target_home/.bashrc" ;;
  esac
}

# 判断文件中是否包含指定关键字（固定字符串匹配）
is_configured() {
  local keyword="$1" file="$2"
  [ -f "$file" ] || return 1
  grep -qF -- "$keyword" "$file"
}

# Configure apm alias
shell_config=$(get_shell_config_file)
# 精确匹配整行: 旧版 alias apm=.../setup.sh 不会被误判为已配置;
# 追加新行后 shell 取最后定义, 旧别名自动失效
if ! is_configured "alias apm=$path/apm" "$shell_config"; then
  echo "alias apm=$path/apm" >>"$shell_config"
fi

if ! is_configured 'thefuck' "$shell_config"; then
  echo 'eval "$(thefuck --alias f)"' >>"$shell_config"
fi
