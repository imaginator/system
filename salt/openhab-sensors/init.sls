openhab-sensors-packages:
  pkg.installed:
    - cache_valid_time: 3600
    - names:
      - git
      - build-essential
      - python-dev
      - python-pip

openhab-sensors-user:
  user.present:
    - name: openhab-sensors
    - fullname: openhab-sensors user
    - home: /home/openhab-sensors
    - createhome: true

paho-mqtt:
  pip.installed

adafruit-dht:
  pip.installed

/home/openhab-sensors/am2302.py:
  file.managed:
    - source: salt://openhab-sensors/files/am2302.py
    - mode: 755

openhab-sensors.service:
  file.managed:
    - name: /etc/systemd/system/openhab-sensors.service
    - source: salt://openhab-sensors/files/am2302.service
    - user: root
    - group: root
    - mode: 644
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: openhab-sensors.service
      - file: /home/openhab-sensors/am2302.py
  service.running:
    - enable: True
    - restart: True
    - require:
      - file: openhab-sensors.service
    - watch:
      - file: /home/openhab-sensors/am2302.py