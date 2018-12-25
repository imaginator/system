prometheus-node-exporter:
  pkg.installed:
    - names:
      - prometheus-node-exporter
      - lm-sensors
  service.running:
    - name: prometheus-node-exporter
    - watch:
      - file: /etc/default/prometheus-node-exporter
    - enable: true
    - require:
      - pkg: prometheus-node-exporter

/usr/share/prometheus-node-exporter/btrfs_stats.py > /var/lib/prometheus/node-exporter/btrfs_stats.prom:
  cron.present:
    - identifier: btrfs-stats-textfile
    - user: root
    - minute: '*/5'

/etc/default/prometheus-node-exporter:
  file.managed:
    - source: salt://prometheus-node-exporter/prometheus-node-exporter
  
firewall-prometheus-node-exporter:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match:
        - state
        - comment
    - comment: "prometheus-node-exporter"
    - connstate: NEW
    - dport: 9100
    - proto: tcp
    - save: True

