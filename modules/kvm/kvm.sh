#!/usr/bin/env bash

brand_condition=`cat /proc/cpuinfo | grep vendor_id | awk  -F":" '{print $2}' | tail -1`
brand='intel' 
user=`whoami`      
path=`dirname $0`

if [ $brand_condition == "GenuineIntel" ]; then
  brand='intel' 
elif [ $brand_condition == "AuthenticAMD" ]; then
  brand='amd' 
else
  echo "cpu brand is unknnow"
  exit 1
fi

sudo pacman -S --noconfirm --needed libvirt qemu-base virt-manager

# 创建网桥
if ! nmcli c show br0 > /dev/null; then
  nmcli con down "Wired connection 1"
  nmcli con add type bridge ifname br0 con-name br0
  nmcli con add type bridge-slave ifname eno1 master br0

  nmcli connection modify br0 ipv4.address 10.7.43.20/24
  nmcli con mod br0 ipv4.gateway 10.7.43.1
  nmcli con mod br0 ipv4.method manual
  nmcli con mod br0 ipv4.dns "10.7.43.1"

  nmcli con up br0
fi

### 创建hook
sudo mkdir -p /etc/libvirt/hooks
sudo chmod 755 /etc/libvirt/hooks

# Copy hook files
sudo cp ${path}/qemu /etc/libvirt/hooks/qemu
sudo cp -rfT ${path}/qemu.d /etc/libvirt/hooks/qemu.d

# Make executable
sudo chmod +x /etc/libvirt/hooks/qemu
sudo chmod -R +x /etc/libvirt/hooks/qemu.d/
###

# iommu kernel
if [ ! -n "$(cat /etc/default/grub | grep intel_iommu=on)" ]; then
  sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="/&intel_iommu=on iommu=pt /' /etc/default/grub
  sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

sudo usermod -aG libvirt $user
