prometheus-server:
  pkg.installed:
    - name: prometheus
  service.running:
    - name: prometheus
    - watch:
      - file: /etc/default/prometheus
      - file: /etc/prometheus/prometheus.yml
    - enable: true
    - require:
      - pkg: prometheus

/etc/default/prometheus:
  file:
    - managed
    - makedirs: true
    - user: root
    - group: root
    - mode: 0755
    - source: salt://prometheus-server/etc_default_prometheus
    - require:
      - pkg: prometheus-server

extract_snmp_exporter:
  archive.extracted:
    - name: /opt/snmp_exporter
    - source: https://github.com/prometheus/snmp_exporter/releases/download/v0.7.0/snmp_exporter-0.7.0.linux-amd64.tar.gz
    - source_hash: sha1=248994f435e5e30081a410ebf5f79912c2926066
    - archive_format: tar
    - tar_options: "--strip-components=1 -v"
    - user: nobody
    - group: nogroup
# waiting for 2016.x to enable this. For now just delete the directory and rerun
#    - source_hash_update: True

/etc/systemd/system/prometheus_snmp_exporter.service:
  file:
    - managed
    - makedirs: true
    - user: root
    - group: root
    - mode: 0755
    - source: salt://prometheus-server/prometheus_snmp_exporter.service
    - require:
      - pkg: prometheus-server

prometheus_snmp_exporter:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - archive: extract_snmp_exporter
      - file: /etc/systemd/system/prometheus_snmp_exporter.service


/etc/prometheus/prometheus.yml:
  file:
    - managed
    - makedirs: true
    - user: root
    - group: root
    - mode: 0755
    - source: salt://prometheus-server/prometheus.yml
    - require:
      - pkg: prometheus-server

/etc/prometheus/snmp.yml:
  file:
    - managed
    - makedirs: true
    - user: root
    - group: root
    - mode: 0755
    - source: salt://prometheus-server/snmp.yml
    - require:
      - archive: extract_snmp_exporter

prometheus-no-copy-on-write:
  cmd.run:
    - name: chattr +C /var/lib/prometheus
