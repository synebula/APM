#!/usr/bin/env bash

# Configure apm alias
if ! is_configured 'apm=' /home/$user/.bashrc; then
  echo "alias apm=$path/setup.sh" | sudo tee -a /home/$user/.bashrc >/dev/null
  echo "eval "$(thefuck --alias f)"" | sudo tee -a /home/$user/.bashrc >/dev/null
fi
