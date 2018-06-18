{% from "lms/map.jinja" import lms with context %}

lms-server:
  pkg.installed:
    - sources:
      - lmsmediaserver: {{ lms.url }}
    - cache_valid_time: 30000
service.running:
    - name: lmsmediaserver
    - enable: True
    - require:
      - pkg: lms-server

/etc/nginx/conf.d/nginx-lms.conf:
  file:
    - managed
    - makedirs: true
    - user: root
    - group: root
    - source: salt://lms/nginx-lms.conf
    - require:
      - pkg: lms-server

lms_iptables-tcp:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: tcp
    - jump: accept-log
    - dports: 32400
    - family: ipv4
    - match: comment 
    - comment: lms-web-tcp
    - save: true

lms_iptables-udp:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: udp
    - jump: accept-log
    - dports: 32400
    - family: ipv4
    - match: comment 
    - comment: lms-udp
    - save: true

lms_iptables-bonjour:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: udp
    - jump: accept-log
    - dports: 5353
    - family: ipv4
    - match: comment 
    - comment: lms-web-udp
    - save: true

/srv/video/TV/lms Versions:
  file.directory:
    - user: lms
    - group: root
    - mode: 755
    - makedirs: True

/srv/video/Film/lms Versions:
  file.directory:
    - user: lms
    - group: root
    - mode: 755
    - makedirs: True

/srv/video/Clips/lms Versions:
  file.directory:
    - user: lms
    - group: root
    - mode: 755
    - makedirs: True