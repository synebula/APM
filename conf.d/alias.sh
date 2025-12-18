#!/usr/bin/env bash

# Configure apm alias
shell_config=$(get_shell_config_file)
if ! is_configured 'apm=' $shell_config; then
  echo "alias apm=$path/setup.sh" >>"$shell_config"
fi

if ! is_configured 'thefuck' $shell_config; then
  echo 'eval "$(thefuck --alias f)"' >>"$shell_config"
fi
