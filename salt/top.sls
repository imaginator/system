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
    - prometheus-server
    - plex
    - nginx
    - grafana
    - mosquitto
    - openhab
    - saltstack-server
    - pulseaudio
#    - gmusicproxy
#    - mopidy
#  pi02:
#    - openhab-kiosk
#    - openhab-sensors
