#!/usr/bin/env bash

# Configure apm alias
if ! is_configured 'apm=' /home/$user/.bashrc; then
  echo "alias apm=$path/install.sh" | sudo tee -a /home/$user/.bashrc
fi
