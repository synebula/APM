#!/usr/bin/env bash

# 判断文件中是否包含指定关键字。
# 用法：is_configured 'keyword' file
is_configured() {
  local keyword="$1"
  local file="$2"

  if [ ! -f "$file" ]; then
    return 1
  fi

  if grep -q -- "$keyword" "$file"; then
    return 0
  fi

  return 1
}

# 判断当前用户使用的 shell 并返回 shell 配置文件路径
get_shell_config_file() {
  local user_shell
  user_shell="$(getent passwd "$USER" | cut -d: -f7)"
  case "$user_shell" in
    /bin/bash)
      echo "$HOME/.bashrc"
      ;;
    /bin/zsh)
      echo "$HOME/.zshrc"
      ;;
    /bin/fish)
      echo "$HOME/.config/fish/config.fish"
      ;;
    *)
      echo "$HOME/.bashrc"
      ;;
  esac
}

# 解析 INI 文件，获取指定 section 下的所有项（不包括 section 标题）
parse_ini_section() {
  local ini="$1"
  local section="$2"

  awk -v section="$section" '
    # 忽略空行和注释行
    /^[[:space:]]*$/ { next }
    /^[[:space:]]*;/ { next }
    /^[[:space:]]*#/ { next }

    # section 标题
    /^\[.*\]/ {
      if ($0 == "[" section "]") {
        in_section = 1
      } else {
        in_section = 0
      }
    }

    # 在目标 section 内的非注释行，输出第一个字段
    in_section && $1 !~ /^\[/ && $1 != "" {
      print $1
    }
  ' "$ini"
}

# 从一组 INI 文件中解析所有包名（忽略注释、空行和 section 标题）
# 用法：parse_all_packages file1.ini file2.ini ...
parse_all_packages() {
  local file
  for file in "$@"; do
    # 通配符未匹配时会保留原样，这里过滤掉不存在的路径
    if [ ! -f "$file" ]; then
      continue
    fi

    sed -e 's/[#;].*$//' \
        -e '/^[[:space:]]*$/d' \
        -e '/^[[:space:]]*\[.*\][[:space:]]*$/d' \
        "$file"
  done
}

# 检查网络连通性：优先使用 curl，不可用时回退到 ping
check_network() {
  local url host

  for url in "https://archlinux.org" "https://mirrors.ustc.edu.cn"; do
    if command -v curl >/dev/null 2>&1; then
      if curl --silent --head --max-time 5 "$url" >/dev/null 2>&1; then
        return 0
      fi
    elif command -v ping >/dev/null 2>&1; then
      host=$(printf '%s\n' "$url" | sed 's~https\?://~~;s~/.*$~~')
      if ping -c 1 -W 5 "$host" >/dev/null 2>&1; then
        return 0
      fi
    else
      break
    fi
  done

  return 1
}
