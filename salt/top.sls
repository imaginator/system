base:
  '*':
    - base-utils
    - time
    - cron
    - groups
    - users
    - prometheus-node-exporter
    - frontail
  bunker:
    - arpwatch
    - frontail
    - grafana
    - letsencrypt
    - kernel
    - logging
    - mosquitto
    - motion
    - network
    - nginx
    - openhab-server
    - plex
    - postfix
    - prometheus-server
    - prometheus-openhab-exporter
    - prometheus-snmp-exporter
    - saltstack-server
    - 
    - samba
  furrow:
    - base-utils
  pi02:
    - openhab-sensors
