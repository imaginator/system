frontail-dependencies:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs:
      - nodejs
      - npm
      - git 

install-frontail:
  npm.installed:
    - pkgs:
      - frontail
    - user: openhab
    - require:
      - pkg: frontail-dependencies

frontail:
  file.managed:
    - name: /etc/systemd/system/frontail.service
    - source: salt:/frontail/files/frontail.service
    - user: root
    - group: root
    - mode: 644
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: /lib/systemd/system/frontail.service
  service.running:
    - enable: True
    - require:
      - file: /lib/systemd/system/frontail.service
    - watch:
      - file: /lib/systemd/system/frontail.service
      - npm: install-frontail
