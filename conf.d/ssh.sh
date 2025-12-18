
#!/usr/bin/env bash

# enable sshd start up
if ! systemctl is-enabled sshd >/dev/null 2>&1; then
  sudo systemctl enable --now sshd
fi
