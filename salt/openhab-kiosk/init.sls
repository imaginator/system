kiosk-requirements-deps:
  pkg.installed:
    - cache_valid_time: 3600
    - names:
      - chromium-browser
      - xserver-xorg-core

openhab-kiosk:
  user.present:
    - fullname: Kiosk display for Openhab Dashboard
    - shell: /bin/false
    - home: /home/openhab-kiosk
    - createhome: true

/home/openhab-kiosk/startup:
  file.managed:
    - source: salt://openhab-kiosk/startup
    - makedirs: True
    - user: root
    - group: root
    - mode: 655
    - require:
      - pkg: kiosk-requirements-deps
      - user: openhab-kiosk

xorg.service:
  file.managed:
    - name: /etc/systemd/system/xorg.service
    - source: salt://openhab-kiosk/xorg.service
    - user: root
    - group: root
    - mode: 644
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: xorg.service
  service.running:
    - enable: True
    - require:
      - file: xorg.service
    - watch:
      - file: /etc/systemd/system/openhab-kiosk.service
      - file: xorg.service

openhab-kiosk.service:
  file.managed:
    - name: /etc/systemd/system/openhab-kiosk.service
    - source: salt://openhab-kiosk/openhab-kiosk.service
    - template: jinja
    - user: root
    - group: root
    - mode: 644
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: openhab-kiosk.service
  service.running:
    - enable: True
    - require:
      - file: openhab-kiosk.service
    - watch:
      - file: /home/openhab-kiosk/startup
      - file: openhab-kiosk.service
