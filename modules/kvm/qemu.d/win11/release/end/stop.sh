#!/usr/bin/env bash
set -x

gpu_driver=0
gpu_nvidia=10
gpu_nouveau=20
gpu_amdgpu=30
gpu_driver_info=/tmp/libvirt_win11_gpu_driver
gpu_slot_info=/tmp/libvirt_win11_gpu_slot
extra_pcies_info=/tmp/libvirt_win11_extra_pcies
gpu_slot=$(cat $gpu_slot_info)

# Attach GPU devices to host
# Use your GPU and HDMI Audio PCI host device
lspci -k -s $gpu_slot | grep $gpu_slot | awk '{print $1}' | sed 's/:/_/;s/\./_/;s/^/pci_0000_/' | xargs virsh nodedev-reattach 
if [ -f "$extra_pcies_info" ]; then
    extra_pcies=$(cat $extra_pcies_info)
    array=($extra_pcies)
    for pcie in "${array[@]}";  do 
        echo $pcie | sed 's/:/_/;s/\./_/;s/^/pci_0000_/' | xargs virsh nodedev-reattach 
    done;
    echo $extra_pcies > $extra_pcies_info
fi

gpu_driver=$(cat $gpu_driver_info)
if [ -n "$gpu_driver" ]; then
    # Load GPU kernel modules
    case $gpu_driver in
    $gpu_nvidia)
        # Load NVIDIA kernel modules
        modprobe nvidia_drm nvidia_modeset nvidia_uvm nvidia
        ;;
    $gpu_nouveau)
        modprobe nouveau
        ;;
    $gpu_amdgpu)
        # Load AMD kernel module
        modprobe amdgpu
        ;;
    esac
fi

# Load vfio module
modprobe vfio_pci
