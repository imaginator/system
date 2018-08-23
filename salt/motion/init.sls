motion:
  service.running:
    - enable: False
    - reload: False
    - watch:
      - file: /etc/motion/motion.conf
      - file: /etc/motion/timelapse.conf
    - require:
      - pkg: motion_pkgs
      - group: motion-in-plex
      - file: /srv/video/netcams

ffserver:
  service.running:
    - enable: False
    - restart: False
    - force: False
    - watch:
      - file: /etc/systemd/system/ffserver.service
      - file: /etc/ffserver.conf

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

/etc/motion/motion.conf:
  file.managed:
    - makedirs: true
    - user: motion
    - group: motion
    - source: salt://motion/files/motion.conf
    - template: jinja
    - require:
      - pkg: motion_pkgs

/etc/motion/timelapse.conf:
  file.managed:
    - makedirs: true
    - user: motion
    - group: motion
    - source: salt://motion/files/timelapse.conf
    - template: jinja
    - require:
      - pkg: motion_pkgs

/etc/ffserver.conf:
  file.managed:
    - makedirs: true
    - user: motion
    - group: motion
    - source: salt://motion/files/ffserver.conf
    - template: jinja
    - require:
      - pkg: motion_pkgs

/etc/nginx/sites-enabled/eyeinthesky.imaginator.com.conf:
  file.managed:
    - source: salt://motion/files/nginx-vhost-eyeinthesky.conf

/etc/systemd/system/ffserver.service:
  file.managed:
    - source: salt://motion/files/ffserver.service

ffserver_iptables_ipv4:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: tcp
    - jump: accept-log
    - dports: 9999
    - family: ipv4
    - match: comment 
    - comment: ffserver-streaming
    - save: true

