#!/usr/bin/env bash

brand_condition=$(awk -F':' '/vendor_id/ {v=$2} END {gsub(/^[[:space:]]+/, "", v); print v}' /proc/cpuinfo)
brand='intel'
user=${USER:-$(whoami)}
path=$(cd "$(dirname "$0")" && pwd)

if [ "$brand_condition" = "GenuineIntel" ]; then
  brand='intel'
elif [ "$brand_condition" = "AuthenticAMD" ]; then
  brand='amd'
else
  echo "cpu brand is unknown"
  exit 1
fi

sudo pacman -S --noconfirm --needed libvirt qemu-full virt-manager

# 创建网桥
if ! nmcli c show br0 >/dev/null 2>&1; then
  nmcli con down "Wired connection 1" || true
  nmcli con add type bridge ifname br0 con-name br0
  nmcli con add type bridge-slave ifname eno1 master br0 con-name eno1-slave

  nmcli con mod br0 ipv4.address 10.7.43.20/24
  nmcli con mod br0 ipv4.gateway 10.7.43.1
  nmcli con mod br0 ipv4.method manual
  nmcli con mod br0 ipv4.dns "10.7.43.1"

  nmcli con up br0

  nmcli -t -f NAME c | sed '1d' | while IFS= read -r c; do
    nmcli c mod "$c" 802-3-ethernet.wake-on-lan magic
  done
fi

### 创建hook
sudo mkdir -p /etc/libvirt/hooks
sudo chmod 755 /etc/libvirt/hooks

# Copy hook files
sudo cp "${path}/qemu" /etc/libvirt/hooks/qemu
sudo cp -rfT "${path}/qemu.d" /etc/libvirt/hooks/qemu.d

# Make executable
sudo chmod +x /etc/libvirt/hooks/qemu
sudo chmod -R +x /etc/libvirt/hooks/qemu.d/
###

if [ ! -f /etc/sysctl.d/bridge.conf ]; then
cat <<'EOF' | sudo tee /etc/sysctl.d/bridge.conf >/dev/null
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 0
net.bridge.bridge-nf-call-iptables = 0
net.bridge.bridge-nf-call-arptables = 0
EOF
sudo sysctl -p /etc/sysctl.d/bridge.conf
fi

# iommu kernel
if [ "$brand" = 'intel' ] && [ -f /etc/default/grub ] && ! grep -q 'intel_iommu=on' /etc/default/grub; then
  sudo sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="/&intel_iommu=on iommu=pt /' /etc/default/grub
  sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

sudo usermod -aG libvirt "$user"
