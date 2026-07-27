#!/usr/bin/env bash
set -x

gpu_driver=0
gpu_nvidia=10
gpu_nouveau=20
gpu_amdgpu=30
gpu_driver_info=/tmp/libvirt_win_gpu_driver
gpu_slot_info=/tmp/libvirt_win_gpu_slot
extra_pcies_info=/tmp/libvirt_win_extra_pcies
gpu_slot=""

bdf_to_nodedev() {
    local bdf="$1"
    bdf="${bdf#0000:}"
    echo "$bdf" | sed 's/:/_/;s/\./_/;s/^/pci_0000_/'
}

reattach_nodedev() {
    local bdf="$1"
    virsh nodedev-reattach "$(bdf_to_nodedev "$bdf")"
}

if [ -f "$gpu_slot_info" ]; then
    gpu_slot="$(cat "$gpu_slot_info")"
fi

# Attach GPU devices to host
# Use your GPU and HDMI Audio PCI host device
if [ -n "$gpu_slot" ]; then
    while read -r bdf; do
        [ -n "$bdf" ] || continue
        reattach_nodedev "$bdf"
    done < <(lspci -D -s "$gpu_slot" | awk '{print $1}')
fi

if [ -f "$extra_pcies_info" ]; then
    extra_pcies="$(cat "$extra_pcies_info")"
    array=($extra_pcies)
    for pcie in "${array[@]}"; do
        reattach_nodedev "$pcie"
    done
    rm -f "$extra_pcies_info"
fi

gpu_driver=""
if [ -f "$gpu_driver_info" ]; then
    gpu_driver="$(cat "$gpu_driver_info")"
fi
if [ -n "$gpu_driver" ]; then
    # Load GPU kernel modules
    case "$gpu_driver" in
    "$gpu_nvidia")
        # Load NVIDIA kernel modules
        modprobe nvidia_drm nvidia_modeset nvidia_uvm nvidia
        ;;
    "$gpu_nouveau")
        modprobe nouveau
        ;;
    "$gpu_amdgpu")
        # Load AMD kernel module
        modprobe amdgpu
        ;;
    esac
fi

# Load vfio module
modprobe vfio_pci
