base:
  '*':
    - base-utils
    - time
    - cron
    - groups
    - users
    - prometheus-node-exporter
  bunker:
    - arpwatch
    - grafana
    - kernel
    - mosquitto
    - motion
    - network
    - logging
    - nginx
    - openhab-server
    - plex
    - postfix
    - prometheus-server
    - prometheus-snmp-exporter
    - saltstack-server
    - samba
  furrow:
    - base-utils
  pi02:
    - openhab-sensors
