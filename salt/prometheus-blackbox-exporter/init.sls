prometheus-blackbox-exporter:
  service.running:
    - enable: True
    - restart: True
    - require:
      - pkg: prometheus-blackbox-exporter-packages
      - file: /etc/prometheus/blackbox.yml
    - onchanges:
      - file: /etc/prometheus/blackbox.yml

prometheus-blackbox-exporter-packages:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs:
      - prometheus-blackbox-exporter

/etc/prometheus/blackbox.yml:
  file.managed:
    - source: salt://prometheus-blackbox-exporter/files/blackbox.yml
    - makedirs: True
    - user: root
    - group: root
