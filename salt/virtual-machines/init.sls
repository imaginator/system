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
      - smbclient

libvirt-copy-on-write:
  file.directory:
    - name: /var/lib/libvirt/images
    - makedirs: True
    - attrs: +C

 /srv/isos:
  file.directory:
    - makedirs: True
