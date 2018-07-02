kvm-packages:
  pkg.installed:
    - pkgs:
      - bridge-utils
      - libvirt-bin
      - virt-goodies
      - virt-manager
      - virt-top
      - virtinst
      - virt-viewer
      - vlan
      - guestmount
      - lvm2
      - qemu-kvm
      - python-libvirt

test
  CPU: 2
  Memory: 524288
  State: running
  Graphics: vnc - hyper6:5900
  Disk - vda:
    Size: 2.0G
    File: test.qcow2
    File Format: qcow2
  Nic - ac:de:48:98:08:77:
    Source: trusted
    Type: bridge