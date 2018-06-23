# disable ip forwarding

net.ipv4.ip_forward:
  sysctl.present:
    - value: 0

net.ipv6.conf.all.forwarding:
  sysctl.present:
    - value: 0 