bind9:
  pkg.installed:
    - name: bind9
  service.running:
    - name: bind9
    - watch:
      - file: /etc/bind/named.conf.options
      - file: /etc/bind/named.conf.local
      - file: /etc/bind/zone-files/*.zonefile
    - enable: true
    - require:
      - pkg: bind9

/etc/bind/zone-files:
  file.directory:
    - mode: 755
    - makedirs: True
    - user: bind
    - group: root
    - mode: 0755
    - require:
      - pkg: bind9
    - recurse:
      - user
      - group
      - mode

/etc/bind/named.conf.options:
  file:
    - managed
    - makedirs: true
    - user: root
    - group: root
    - mode: 0755
    - source: salt://bind9/named.conf.options
    - require:
      - pkg: bind9

/etc/bind/named.conf.local:
  file:
    - managed
    - makedirs: true
    - user: root
    - group: root
    - mode: 0755
    - source: salt://bind9/named.conf.local
    - require:
      - pkg: bind9

firewall-bind9-udp:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: accept-log
    - match: state
    - connstate: NEW
    - dport: 53
    - proto: udp
    - family: ipv4
    - save: True
    - match: comment
    - comment: firewall-bind9-udp
    - save: true

firewall-bind9-tcp:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: accept-log
    - match: state
    - connstate: NEW
    - dport: 53
    - proto: tcp
    - family: ipv4
    - save: True
    - match: comment
    - comment: firewall-bind9-tcp
    - save: true

firewall-bind9-udp-ipv6:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: accept-log
    - match: state
    - connstate: NEW
    - dport: 53
    - proto: udp
    - family: ipv6
    - save: True
    - match: comment
    - comment: firewall-bind9-udp
    - save: true

firewall-bind9-tcp-ipv6:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: accept-log
    - match: state
    - connstate: NEW
    - dport: 53
    - proto: tcp
    - family: ipv6
    - save: True
    - match: comment
    - comment: firewall-bind9-tcp
    - save: true

