{% from "plex/map.jinja" import plex with context %}

plex-server:
  pkg.installed:
    - sources:
      - plexmediaserver: {{ plex.url }}
    - cache_valid_time: 30000

  service.running:
    - name: plexmediaserver
    - enable: True
    - require:
      - pkg: plex-server

/etc/nginx/conf.d/nginx-plex.conf:
  file:
    - managed
    - makedirs: true
    - user: root
    - group: root
    - source: salt://plex/nginx-plex.conf
    - require:
      - pkg: nginx-full
      - pkg: plex-server

plex_iptables-tcp:
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
    - comment: plex-web-tcp
    - save: true

plex_iptables-udp:
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
    - comment: plex-udp
    - save: true

plex_iptables-bonjour:
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
    - comment: plex-web-udp
    - save: true

/srv/video/TV/Plex Versions:
  file.directory:
    - user: plex
    - group: root
    - mode: 755
    - makedirs: True

/srv/video/Film/Plex Versions:
  file.directory:
    - user: plex
    - group: root
    - mode: 755
    - makedirs: True

/srv/video/Clips/Plex Versions:
  file.directory:
    - user: plex
    - group: root
    - mode: 755
    - makedirs: True
