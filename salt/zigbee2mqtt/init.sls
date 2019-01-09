zigbee2mqtt-dependencies:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs:
      - nodejs
      - npm
      - git
      - make
      - g++
      - gcc

zigbee2mqtt-git:
  git.latest:
    - name: https://github.com/Koenkk/zigbee2mqtt.git
    - target: /opt/zigbee2mqtt
    - user: openhab
    - force: True
    - require:
      - pkg: zigbee2mqtt-dependencies

zigbee2mqtt-config:
    file.managed:
      - name: /opt/zigbee2mqtt/data/configuration.yaml
      - src: salt://zigbee2mqtt/files/configuration.yaml

zigbee2mqtt.service:
  file.managed:
    - name: /etc/systemd/system/zigbee2mqtt.service
    - source: salt:/zigbee2mqtt/files/zigbee2mqtt.service
    - user: root
    - group: root
    - mode: 644
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: zigbee2mqtt
  service.running:
    - enable: True
    - require:
      - file: zigbee2mqtt
    - watch:
      - file: zigbee2mqtt-config
      - file: zigbee2mqtt.service
