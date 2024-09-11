
#!/usr/bin/env bash

apm -S --noconfirm --needed openssh
# enable sshd start up
if [ ! $(systemctl is-enabled sshd) == 'enabled' ]; then
  sudo systemctl enable sshd
fi
