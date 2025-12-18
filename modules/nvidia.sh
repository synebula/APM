#!/usr/bin/env bash

sudo pacman -S --noconfirm --needed nvidia

# sudo modprobe -r nouveau

# if [ ! -f /etc/modprobe.d/blacklist-nouveau.conf ]; then
#   sudo bash -c 'cat >/etc/modprobe.d/blacklist-nouveau.conf <<EFO
# blacklist nouveau
# options nouveau modeset=0
# EFO'
# fi

if [ -f /etc/default/grub ] && ! grep -q 'nvidia_drm.modeset=1' /etc/default/grub; then
  sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="/&nvidia_drm.modeset=1 /' /etc/default/grub
  sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

if [ -f /etc/mkinitcpio.conf ] && grep -q ' kms' /etc/mkinitcpio.conf; then
  sudo sed -i 's/ kms//' /etc/mkinitcpio.conf
  sudo mkinitcpio -P
fi
