mosquitto:
  pkg.installed:
    - service.running:
      - enable: true

/etc/systemd/system/prometheus-openhab-exporter.service:
  file:
    - managed
    - makedirs: true
    - user: root
    - group: root
    - mode: 0644
    - source: salt://prometheus-openhab-exporter/files/prometheus-openhab-exporter.service
    - require:
      - archive: extract_openhab_exporter

prometheus-openhab-exporter.service:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - archive: extract_openhab_exporter
      - file: /etc/systemd/system/prometheus-openhab-exporter.service
