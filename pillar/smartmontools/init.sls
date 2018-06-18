# vim: ft=yaml
# Custom Pillar Data for smartmontools

smartmontools:
  enabled: true
  service:
    name: smartd
    state: running
    enable: true
  default:
    start_smartd: "yes"
  config:
    devices:
      '/dev/disk/by-path/pci-0000:00:1f.2-ata-1': '-m simon@imaginator.com'
      '/dev/disk/by-path/pci-0000:00:1f.2-ata-2': '-m simon@imaginator.com'
      '/dev/disk/by-path/pci-0000:00:1f.2-ata-3': '-m simon@imaginator.com'
      '/dev/disk/by-path/pci-0000:00:1f.2-ata-4': '-m simon@imaginator.com'