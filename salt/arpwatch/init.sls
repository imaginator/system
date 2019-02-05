arpwatch:
  service.disabled

arpwatch@trusted:
  service.running: 
    - enable: True
    - restart: True
    - watch:
      - file: /etc/default/arpwatch
    - require:
      - file: /etc/default/arpwatch

arpwatch@notrust:
  service.running:
    - enable: True
    - restart: True
    - watch:
      - file: /etc/default/arpwatch
    - require:
      - file: /etc/default/arpwatch

arpwatch_pkgs:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs:
      - arpwatch

/etc/default/arpwatch:
  file.managed:
    - source: salt://arpwatch/files/arpwatch
    - user: root
    - group: root
    - mode: 644

