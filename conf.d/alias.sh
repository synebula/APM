#!/usr/bin/env bash

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
