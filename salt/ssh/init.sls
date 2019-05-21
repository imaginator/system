# Set up a iptables chain for the service.
sshd-chain:
  iptables.chain_present:
  - names:
    - 'SSHSCAN'
  - family: 'ipv4'
# Set up the iptable rules.
flush-sshscan:
  iptables.flush:
    - chain: 'SSHSCAN'

sshd-rules:
  iptables.append:
  - names:
    - 'SSH Connections':
      - chain: 'INPUT'
      - jump: 'SSHSCAN'
      - dport: '22'
      - i: '!lo'
      - connstate: 'NEW'
      - comment: "SSH flood limiter"
    - 'SSHD Accept from Internal':
      - jump: 'ACCEPT'
      - source: 10.7.8.0/21
      - comment: "Allow from internal"
    - 'SSHD Set':
      - match: 'recent --set --name SSH --rsource'
      - connstate: 'NEW'
    - 'SSHD Log':
      - match: 'recent --update --name SSH --rsource'
      - jump: 'LOG'
      - log-prefix: '[SSH Brute-Force attempt:] '
      - log-level: '7'
      - seconds: '120'
      - hitcount: '5'
    - 'SSHD Drop':
      - jump: 'DROP'
      - match: 'recent --update --name SSH --rsource'
      - connstate: 'NEW'
      - seconds: '120'
      - hitcount: '5'
    - 'SSHD Accept':
      - jump: 'ACCEPT'
      - source: 0.0.0.0/0
  - chain: 'SSHSCAN'
  - proto: 'tcp'
  - table: filter
  - save: True
