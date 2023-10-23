#!/usr/bin/env bash

sudo pacman -S --noconfirm --needed zfs-dkms
sudo systemctl enable --now zfs-mount.service
sudo systemctl enable --now zfs-import-cache.service
sudo systemctl enable --now zfs.target
sudo systemctl enable --now zfs-import.target