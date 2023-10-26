#!/usr/bin/env bash
set -x

gpu_driver=0
gpu_nvidia=10
gpu_nouveau=20
gpu_amdgpu=30
gpu_driver_info=/tmp/libvirt_win11_gpu_driver
pci_slot="01:00"

# Xpad affects the work of the xbox controller and its wireless adapter
# The xpad will shake hands with the handle/wireless adapter when it is plugged in. At this time,
# if you pass the usb device directly to the virtual machine, the xbox handle will not re-handshake with the root of windows,
# which will eventually cause it to fail to work.
# I can't find a way to make the usb device passthrough into the virtual machine from before/when it is plugged in,
# so I suggest you disable this driver if you need to use the gamepad in virtual machine
modprobe -r xpad

# dGPU PCI slots

get_gpu_driver() {
    gpu_driver=$(lsmod | grep nvidia)
    if [ -n "$gpu_driver" ]; then
        return $gpu_nvidia
    fi
    gpu_driver=$(lsmod | grep nouveau)
    if [ -n "$gpu_driver" ]; then
        return $gpu_nouveau
    fi
    gpu_driver=$(lsmod | grep amdgpu)
    return $gpu_amdgpu
}

# Determine whether the graphics card has been used by VFIO kernel modules
if [ -z "$(lspci -k -s $pci_slot | grep vfio-pci)" ]; then
    # Determine whether nvidia kernel modules has been loaded
    get_gpu_driver
    gpu_driver=$?

    if [ $gpu_driver -ne 0 ]; then
        # Stop display manager
        systemctl stop gdm
        sleep 2

        # Unload GPU kernel modules
        case $gpu_driver in
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
        echo $gpu_driver > $gpu_driver_info

        # Detach GPU devices from host
        # Use your GPU and HDMI Audio PCI host device
        virsh nodedev-detach pci_0000_01_00_0
        virsh nodedev-detach pci_0000_01_00_1

        # Load vfio module
        modprobe vfio_pci

        # Restart Display Manager
        systemctl start gdm
    fi
fi
