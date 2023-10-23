#!/usr/bin/env bash
set -x

# Load Xpad
modprobe nvidia_drm nvidia_modeset nvidia_uvm nvidia xpad
if [ ! -n $(lsmod | grep nvidia) ]; then
    modprobe nouveau
fi

# Attach GPU devices to host
# Use your GPU and HDMI Audio PCI host device
virsh nodedev-reattach pci_0000_01_00_0
virsh nodedev-reattach pci_0000_01_00_1

# Unload vfio module
modprobe -r vfio_pci