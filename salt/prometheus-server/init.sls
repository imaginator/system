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
    - mode: 0644
    - source: salt://prometheus-server/etc_default_prometheus
    - require:
      - pkg: prometheus-server

/etc/prometheus/prometheus.yml:
  file:
    - managed
    - makedirs: true
    - user: root
    - group: root
    - mode: 0644
    - source: salt://prometheus-server/prometheus.yml
    - require:
      - pkg: prometheus-server

prometheus-no-copy-on-write:
  cmd.run:
    - name: chattr +C /var/lib/prometheus

firewall-prometheus-server:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: 
        - state
        - comment
    - comment: "prometheus-server"
    - connstate: NEW
    - source: 10.7.8.0/22
    - dport: 9090
    - proto: tcp
    - save: True
