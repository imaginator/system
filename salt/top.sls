base:
  '*':
    - base-utils
    - time
    - cron
    - groups
    - users
    - prometheus-node-exporter
  bunker:
    - grafana
    - kernel
    - mosquitto
    - motion
    - network
    - logging
    - nginx
    - openhab
    - plex
    - prometheus-server
    - prometheus-snmp-exporter
    - saltstack-server
    - samba
  furrow:
    - base-utils
  pi02:
    - openhab-sensors
