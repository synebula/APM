#!/usr/bin/env bash

# Configure apm alias
shell_config=$(get_shell_config_file)
if ! is_configured 'apm=' $shell_config; then
  echo "alias apm=$path/setup.sh" | sudo tee -a $shell_config >/dev/null
fi

if ! is_configured 'thefuck' $shell_config; then
  echo 'eval "$(thefuck --alias f)"' | sudo tee -a $shell_config >/dev/null
fi
