extract_openhab_exporter:
  archive.extracted:
    - name: /opt/openhab_exporter
    - if_missing: /opt/openhab_exporter/openhab_exporter
    - source: https://github.com/imaginator/openhab2-prometheus-exporter/archive/0.1.tar.gz
    - source_hash: 995bba7b430200749df953586017729f6b859116
    - archive_format: tar
    - options: "--strip-components=1"
    - enforce_toplevel: False
    - user: nobody
    - group: nogroup
# waiting for 2016.x to enable this. For now just delete the directory and rerun
#    - source_hash_update: True

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
