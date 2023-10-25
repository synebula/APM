#!/usr/bin/env bash
set -x

gpu_driver=0
gpu_nvidia=10
gpu_nouveau=20
gpu_amdgpu=30
gpu_driver_info=/tmp/libvirt_win11_gpu_driver

# Attach GPU devices to host
# Use your GPU and HDMI Audio PCI host device
virsh nodedev-reattach pci_0000_01_00_0
virsh nodedev-reattach pci_0000_01_00_1

gpu_driver=$(cat $gpu_driver_info)
if [ -n "$gpu_driver" ]; then
    # Load GPU kernel modules
    case $gpu_driver in
    $gpu_nvidia)
        # Load NVIDIA kernel modules
        modprobe nvidia_drm nvidia_modeset nvidia_uvm nvidia xpad
        ;;
    $gpu_nouveau)
        modprobe nouveau xpad
        ;;
    $gpu_amdgpu)
        # Load AMD kernel module
        modprobe amdgpu xpad
        ;;
    esac
fi

# Load vfio module
modprobe vfio_pci
