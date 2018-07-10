kvm-packages:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs:
      - bridge-utils
      - libvirt-bin
      - libguestfs-tools
      - virt-goodies
      - virt-manager
      - virt-top
      - virtinst
      - virt-viewer
      - vlan
      - lvm2
      - qemu-kvm
      - python-libvirt

libvirt-copy-on-write:
  file.directory:
    - name: /tmp/test2
    - makedirs: True
    - attrs: +C
