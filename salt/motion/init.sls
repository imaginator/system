motion:
  service.running:
    - enable: True
    - reload: True
    - watch:
      - file: /etc/motion
    - require:
      - pkg: motion_pkgs
      - group: motion-in-plex
      - file: /srv/video/netcams

reload-nginx-if-config-changes:
  service.running:
    - name: nginx
    - reload: True
    - watch:
      - file: /etc/nginx/sites-enabled/eyeinthesky.imaginator.com.conf
      - file: /etc/nginx/rtmp.conf

motion_pkgs:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs:
      - motion
      - ffmpeg
      - libnginx-mod-rtmp

motion-in-plex:
  group.present:
    - name: motion
    - system: True
    - addusers:
      - plex

/srv/video/netcams:
  file.directory:
    - user: motion
    - group: motion
    - dir_mode: 755
    - file_mode: 644
    - recurse:
      - user
      - group
      - mode
    - require: 
      - group: motion-in-plex

/etc/nginx/rtmp.conf:
  file.managed:
    - source: salt://motion/files/rtmp.conf

/etc/nginx/sites-enabled/eyeinthesky.imaginator.com.conf:
  file.managed:
    - source: salt://motion/files/nginx-vhost-eyeinthesky.conf

/var/web/eyeinthesky.imaginator.com:
  file.recurse:
    - makedirs: true
    - user: www-data
    - group: www-data
    - source: salt://motion/files/html
    - template: jinja

/etc/motion:
  file.recurse:
    - makedirs: true
    - user: motion
    - group: motion
    - source: salt://motion/files/motion-configs
    - template: jinja
    - require:
      - pkg: motion_pkgs

ffserver_iptables_ipv4:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: tcp
    - jump: accept-log
    - dports: 1935
    - family: ipv4
    - match: comment 
    - comment: rtmp-streaming
    - save: true