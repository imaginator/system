#!/bin/sh
set -x

# KMS Client Setup Key
# Windows 10 Professional: W269N-WFGWX-YVC9B-4J6C9-T83GX

virsh list --all

virt-install \
    --name=win10 \
    --memory=4096 \
    --cpu=host \
    --vcpus=2 \
    --os-type=windows \
    --os-variant=win8.1 \
    --network bridge=trusted,model=e1000,mac=52:54:00:6e:6c:42 \
    --boot cdrom,hd \
    --disk size=14,format=qcow2,device=disk,bus=sata,cache=unsafe \
    --disk path=/home/simon/Win10_English_x64.iso,readonly=on,device=cdrom,bus=sata \
    --graphics vnc,listen=127.0.0.1
