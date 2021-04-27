{% from "plex/map.jinja" import plex with context %}

plex-repo:
  pkgrepo.managed:
    - name: deb https://downloads.plex.tv/repo/deb public main
    - humanname: plex repo
    - key: https://downloads.plex.tv/plex-keys/PlexSign.key

plex-server:
  pkg.installed:
    - pkgs:
      - plexmediaserver
    - cache_valid_time: 30000
    - require: 
      - pkgrepo: plex-repo

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
      - pkg: plex-server

{% for mediadir in ['/srv/video/TV', '/srv/video/Film', '/srv/music','/srv/audiobooks'] %}

set-{{ mediadir }}-permissions:
  file.directory:
    - name: {{mediadir}}
    - user: simon
    - group: media
    - dir_mode: 755
    - file_mode: 644
    - recurse:
      - user
      - group
      - mode

set-{{ mediadir }}-permissions-on-parent-folders:
  file.directory:
    - name: {{mediadir}}
    - user: simon
    - group: media
    - dir_mode: 775

{{ mediadir }}/Plex Versions:
  file.directory:
    - user: plex
    - group: root
    - mode: 755
    - makedirs: True

{% endfor %}

plex_iptables-tcp:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: tcp
    - jump: ACCEPT
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
    - jump: ACCEPT
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
    - jump: ACCEPT
    - dports: 5353
    - family: ipv4
    - match: comment 
    - comment: plex-web-udp
    - save: true