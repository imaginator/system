nginx-server:
  service.running:
    - name: nginx
    - enable: True
    - reload: True
    - require:
      - pkg: motion_pkgs
      - file: /srv/video/netcams

reload-nginx-if-config-changes:
  service.running:
    - name: nginx
    - reload: True
    - watch:
      - file: /etc/nginx/sites-enabled/eyeinthesky.imaginator.com.conf

motion_pkgs:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs:
      - ffmpeg

/srv/video/netcams:
  file.directory:
    - user: www-data
    - group: www-data
    - dir_mode: 755
    - file_mode: 644
    - recurse:
      - user
      - group
      - mode

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

record-video-camera01.service:
  file.managed:
    - name: /etc/systemd/system/record-video-camera01.service
    - source: salt://motion/files/record-video-camera01.service
    - user: root
    - group: root
    - mode: 644
    - template: jinja
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: record-video-camera01.service
  service.dead:
    - enable: False
    - require:
      - file: record-video-camera01.service
    - watch:
      - file: record-video-camera01.service

record-video-camera02.service:
  file.managed:
    - name: /etc/systemd/system/record-video-camera02.service
    - source: salt://motion/files/record-video-camera02.service
    - user: root
    - group: root
    - mode: 644
    - template: jinja
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: record-video-camera02.service
  service.running:
    - enable: True
    - require:
      - file: record-video-camera02.service
    - watch:
      - file: record-video-camera02.service