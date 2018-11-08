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
    - mosquitto
    - openhab
    - network
    - plex
    - prometheus-server
    - prometheus-snmp-exporter
    - pulseaudio
    - saltstack-server
    - motion
  furrow:
    - base-utils
  pi02:
    - openhab-sensors
