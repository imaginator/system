rsyslog-packages:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs:
      - rsyslog
      - logrotate

rsyslog-config:
    file.managed:
      - name: /etc/rsyslog.d/10-remote.conf
      - source: salt://logging/files/10-remote.conf
      - makedirs: true
      - user: root
      - group: root
      - mode: 0644

/etc/logrotate.d/logrotate-remote-hosts.conf:
    file.managed:
      - source: salt://logging/files/logrotate-remote-hosts.conf
      - makedirs: true
      - user: root
      - group: root
      - mode: 0644

rsyslog-service:
  service.running:
    - name: rsyslog
    - enable: True
    - restart: True
    - require:
      - pkg: rsyslog-packages
    - watch:
      - file: rsyslog-config

rsyslog-iptables-accept-ipv4-tcp:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: tcp
    - jump: ACCEPT
    - source: 10.7.10.0/21
    - dport: 514
    - family: ipv4
    - match: comment 
    - comment: "rsyslog TCP"
    - save: true

rsyslog-iptables-accept-ipv4-udp:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: udp
    - jump: ACCEPT
    - source: 10.7.10.0/21
    - dport: 514
    - family: ipv4
    - match: comment 
    - comment: "rsyslog UDP"
    - save: true

