prometheus-node-exporter:
  pkg.installed:
    - name: prometheus-node-exporter
  service.running:
    - name: prometheus-node-exporter
    - watch:
      - file: /etc/default/prometheus-node-exporter
    - enable: true
    - require:
      - pkg: prometheus-node-exporter

/etc/default/prometheus-node-exporter:
  file.managed:
    - source: salt://prometheus-node-exporter/prometheus-node-exporter
  
firewall-prometheus-node-exporter:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: accept-log
    - match: state
    - connstate: NEW
    - dport: 9100
    - proto: tcp
    - save: True
    - match: comment
    - comment: firewall-prometheus-node-exporter
    - save: true
