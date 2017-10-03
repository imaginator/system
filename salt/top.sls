base:
  '*':
    - base-utils
    - time
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
  pi02:
    - openhab-kiosk
    - openhab-sensors
