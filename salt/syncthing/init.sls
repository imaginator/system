bunker-lxc:
  # the provider to use
  provider: bunker-lxc
  lxc_profile:
      template: ubuntu
  network_profile: bunker-lxc
  minion:
     master: 10.0.2.15
     master_port: 4506

syncthing-lxc:
  cloud.profile:
    - profile: bunker-lxc

lxc-firewall:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: accept-log
    - match: state
    - connstate: NEW
    - dport: 4505:4506
    - source: '10.7.11.0/24'
    - proto: tcp
    - save: True

syncthing-lxc-running:
  lxc.running:
    - name: syncthing-lxc
