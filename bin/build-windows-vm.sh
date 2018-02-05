#!/bin/sh
set -x

virt-install \
  --connect qemu:///system \
  --name win10knx \
  --ram 2048 \
  --vcpus=2 \
  --network=network=default,model=virtio,mac=RANDOM \
  --graphics vnc,port=5900 \
  --disk device=cdrom,path=/home/simon/Win10_English_x64.iso \
  --disk path=/tmp/win7.qcow2,bus=virtio,size=100,format=qcow2 \
  --os-type=windows \
  --os-variant=win7 \
  --boot cdrom,hd 
    
