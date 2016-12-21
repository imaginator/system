grafana-repo:
  pkgrepo:
    - managed
    - key_url: https://packagecloud.io/gpg.key
    - name: deb https://packagecloud.io/grafana/stable/debian/ wheezy main
    - refresh_db: true

grafana-pkg:
  pkg:
    - installed
    - name: grafana
    - require:
      - pkgrepo: grafana-repo

/etc/grafana/grafana.ini:
  file:
    - managed
    - makedirs: true
    - user: grafana
    - group: grafana
    - source: salt://grafana/grafana.ini
    - template: jinja
    - require:
      - pkg: grafana-pkg

grafana-server:
  service:
    - running
    - enable: true
    - require:
      - pkg: grafana-pkg
    - watch:
      - file: /etc/grafana/*

/etc/nginx/conf.d/nginx-grafana.conf:
  file:
    - managed
    - makedirs: true
    - user: root
    - group: root
    - source: salt://grafana/nginx-grafana.conf
    - require:
      - pkg: nginx-full
      - pkg: grafana
