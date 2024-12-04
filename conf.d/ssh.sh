
#!/usr/bin/env bash

# enable sshd start up
if [ ! $(systemctl is-enabled sshd) == 'enabled' ]; then
  sudo systemctl enable sshd
fi
