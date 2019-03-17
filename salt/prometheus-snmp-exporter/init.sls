extract_snmp_exporter:
  archive.extracted:
    - name: /opt/snmp_exporter
    - if_missing: /opt/snmp_exporter/snmp_exporter
    - source: https://github.com/prometheus/snmp_exporter/releases/download/v0.15.0/snmp_exporter-0.15.0.linux-amd64.tar.gz
    - source_hash: sha1=6949ef62fa0185f903ff3aabadc245129edc1702
    - archive_format: tar
    - options: "--strip-components=1"
    - enforce_toplevel: False
    - user: nobody
    - group: nogroup
# waiting for 2016.x to enable this. For now just delete the directory and rerun
#    - source_hash_update: True

/etc/prometheus/snmp.yml:
  file:
    - managed
    - makedirs: true
    - user: root
    - group: root
    - mode: 0644
    - source: salt://prometheus-snmp-exporter/files/snmp.yml
    - require:
      - archive: extract_snmp_exporter

/etc/systemd/system/prometheus_snmp_exporter.service:
  file:
    - managed
    - makedirs: true
    - user: root
    - group: root
    - mode: 0644
    - source: salt://prometheus-snmp-exporter/files/prometheus_snmp_exporter.service
    - require:
      - file: /etc/prometheus/snmp.yml

prometheus_snmp_exporter:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - archive: extract_snmp_exporter
      - file: /etc/systemd/system/prometheus_snmp_exporter.service
