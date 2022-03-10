mosquitto:
  pkg.installed:
    - service.running:
      - enable: true



mosquitto-ipv4-iptables:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - source: 10.7.8.0/22
    - match:
        - state
        - comment
    - comment: "mosquitto input"
    - connstate: NEW
    - dport: 1883
    - proto: tcp
    - save: True