frontail-dependencies:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs:
      - nodejs
      - npm
      - git

/opt/frontail:
  file.directory:
    - makedirs: True

install-frontail:
  npm.installed:
    - name: frontail
    - dir: /opt/frontail
    - require:
      - pkg: frontail-dependencies
      - file: /opt/frontail

/opt/frontail/preset.json:
  file.managed:
    - makedirs: true
    - user: openhab
    - group: openhab
    - source: salt://frontail/files/preset.json
    - require:
      - npm: install-frontail

frontail:
  file.managed:
    - name: /etc/systemd/system/frontail.service
    - source: salt://frontail/files/frontail.service
    - user: root
    - group: root
    - mode: 644
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: frontail
  service.running:
    - enable: True
    - require:
      - file: frontail
      - file: /opt/frontail/preset.json
    - watch:
      - file: frontail
      - npm: install-frontail
