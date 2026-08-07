#!/usr/bin/env bash
set -euo pipefail

gpu_driver=0
gpu_nvidia=10
gpu_nouveau=20
gpu_amdgpu=30
gpu_driver_info=/tmp/libvirt_win_gpu_driver
gpu_slot="01:00"
gpu_slot_info=/tmp/libvirt_win_gpu_slot
extra_pcies="09:00.0" # allow multi pcie, separated by space. like '08:00.1 09:00.2'
extra_pcies_info=/tmp/libvirt_win_extra_pcies

# Xpad affects the work of the xbox controller and its wireless adapter
# The xpad will shake hands with the handle/wireless adapter when it is plugged in. At this time,
# if you pass the usb device directly to the virtual machine, the xbox handle will not re-handshake with the root of windows,
# which will eventually cause it to fail to work.
# I can't find a way to make the usb device passthrough into the virtual machine from before/when it is plugged in,
# so I suggest you disable this driver if you need to use the gamepad in virtual machine
# modprobe -r xpad xone_dongle xone_gip xone_gip_gamepad

# dGPU PCI slots

get_gpu_driver() {
    local driver
    driver=$(lspci -k -s "$gpu_slot" | awk -F': ' '/Kernel driver in use/ {print $2; exit}')
    if [[ "$driver" == *nvidia* ]]; then
        return $gpu_nvidia
    fi
    if [[ "$driver" == *nouveau* ]]; then
        return $gpu_nouveau
    fi
    if [[ "$driver" == *amdgpu* ]]; then
        return $gpu_amdgpu
    fi
    return 0
}

# Determine whether the graphics card has been used by VFIO kernel modules
if [ -z "$(lspci -k -s "$gpu_slot" | grep vfio-pci)" ]; then
    # Determine whether nvidia kernel modules has been loaded
    # 返回值即驱动类型（10/20/30）; 必须用 || 捕获, 否则 set -e 下直接终止脚本
    get_gpu_driver || gpu_driver=$?

    if [ "$gpu_driver" -ne 0 ]; then
        # Stop display manager
        systemctl stop gdm
        sleep 2

        # Unload GPU kernel modules
        case "$gpu_driver" in
        $gpu_nvidia)
            # Unload NVIDIA kernel modules
            modprobe -r nvidia_drm nvidia_modeset nvidia_uvm nvidia
            ;;
        $gpu_nouveau)
            modprobe -r nouveau
            ;;
        $gpu_amdgpu)
            # Unload AMD kernel module
            modprobe -r amdgpu
            ;;
        esac
        echo "$gpu_driver" > "$gpu_driver_info"

        # Detach GPU devices from host
        if ! lspci -k -s "$gpu_slot" | grep "$gpu_slot" | awk '{print $1}' | sed 's/:/_/;s/\./_/;s/^/pci_0000_/' | xargs virsh nodedev-detach; then
            echo "ERROR: Failed to detach GPU devices at slot $gpu_slot" >&2
            systemctl start gdm
            exit 1
        fi
        echo "$gpu_slot" > "$gpu_slot_info"

        # Load vfio module
        modprobe vfio_pci

        # Restart Display Manager
        systemctl start gdm
    fi
fi

if [ -n "$extra_pcies" ]; then
    read -ra pcie_array <<< "$extra_pcies"
    for pcie in "${pcie_array[@]}"; do
        nodedev=$(echo "$pcie" | sed 's/:/_/;s/\./_/;s/^/pci_0000_/')
        if ! virsh nodedev-detach "$nodedev"; then
            echo "ERROR: Failed to detach PCIe device $pcie" >&2
            exit 1
        fi
    done
    echo "$extra_pcies" > "$extra_pcies_info"
fi
