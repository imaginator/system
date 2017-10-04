openhab-sensors-packages:
  pkg.installed:
    - cache_valid_time: 3600
    - names:
      - git
      - build-essential
      - python-dev
      - python-pip
      - python-virtualenv

openhab-sensors-user:
  user.present:
    - name: openhab-sensors
    - fullname: openhab-sensors user
    - home: /home/openhab-sensors
    - createhome: true

openhab-sensors_venv:
  virtualenv.managed:
    - name: /home/openhab-sensors/Adafruit_Python_DHT
    - user: openhab-sensors
    - require:
      - pkg: openhab-sensors-packages

adafruit-dht_git:
  git.latest:
    - name: https://github.com/adafruit/Adafruit_Python_DHT.git
    - target: /home/openhab-sensors/adafruit
    - user: openhab-sensors
    - force: True
    - require:
      - pkg: git
      - virtualenv: openhab-sensors_venv

adafruit-dht_install_pkgs:
  pip.installed:
    - bin_env: openhab-sensors_venv
    - requirements: /home/openhab-sensors/Adafruit_python_DHT/requirements.txt
    - require:
      - git: adafruit-dht_git
      - pkg: openhab-sensors-packages
      - virtualenv: openhab-sensors_venv

openhab-sensors.service:
  file.managed:
    - name: /etc/systemd/system/openhab-sensors.service
    - source: salt://openhab-sensors/files/openhab-sensors.service
    - user: root
    - group: root
    - mode: 644
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: openhab-sensors.service
  service.running:
    - enable: True
    - require:
      - file: openhab-sensors.service

