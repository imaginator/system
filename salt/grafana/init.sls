grafana-server:
  service:
    - enable: True
    - running
    - require:
      - pkg: grafana_pkgs
    - watch:
      - file: /etc/grafana/*

grafana_pkgs:
  pkg.installed:
    - pkgs:
      - grafana
    - require:
      - pkgrepo: grafana-repo

grafana-repo:
  pkgrepo:
    - managed
    - key_url: https://packages.grafana.com/gpg.key
    - name: deb https://packages.grafana.com/oss/deb stable main
    - refresh_db: true

/etc/grafana/grafana.ini:
  file:
    - managed
    - makedirs: true
    - user: grafana
    - group: grafana
    - source: salt://grafana/grafana.ini
    - template: jinja
    - require:
      - pkg: grafana_pkgs

/etc/nginx/conf.d/nginx-grafana.conf:
  file:
    - managed
    - makedirs: true
    - user: root
    - group: root
    - source: salt://grafana/nginx-grafana.conf
    - require:
      - pkg: grafana_pkgs
