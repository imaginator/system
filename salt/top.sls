base:
  '*':
    - base-utils
    - time
    - cron
    - groups
    - users
    - prometheus-node-exporter
  bunker:
    - network
    - letsencrypt
    - prometheus-server
    - plex
    - nginx
    - grafana
    - gmusicproxy
    - mosquitto
    - openhab
    - saltstack-server
  pi02:
    - openhab-kiosk
    - openhab-sensors
