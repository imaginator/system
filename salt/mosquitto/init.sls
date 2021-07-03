mosquitto:
  pkg.installed:
    - service.running:
      - enable: true

mosquitto-ipv4-iptables:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: tcp
    - jump: ACCEPT
    - source: 10.7.8.0/22
    - dport: 1883
    - family: ipv4
    - match: comment 
    - comment: "mosquitto input"
    - save: True