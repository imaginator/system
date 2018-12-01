nginx:
  service.running:
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
      - file: /etc/nginx/rtmp.conf

motion_pkgs:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs:
      - ffmpeg
      - libnginx-mod-rtmp

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

/etc/nginx/rtmp.conf:
  file.managed:
    - source: salt://motion/files/rtmp.conf
    - template: jinja

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

multicast-publisher.service:
  file.managed:
    - name: /etc/systemd/system/multicast-publisher.service
    - source: salt://motion/files/multicast-publisher.service
    - user: root
    - group: root
    - mode: 644
    - template: jinja
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: multicast-publisher.service
  service.running:
    - enable: True
    - require:
      - file: multicast-publisher.service
    - watch:
      - file: multicast-publisher.service

webcam-publisher.service:
  file.managed:
    - name: /etc/systemd/system/webcam-publisher.service
    - source: salt://motion/files/webcam-publisher.service
    - user: root
    - group: root
    - mode: 644
    - template: jinja
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: webcam-publisher.service
  service.running:
    - enable: True
    - require:
      - file: webcam-publisher.service
    - watch:
      - file: webcam-publisher.service

archive-video.service:
  file.managed:
    - name: /etc/systemd/system/archive-video.service
    - source: salt://motion/files/archive-video.service
    - user: root
    - group: root
    - mode: 644
    - template: jinja
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: archive-video.service
  service.running:
    - enable: True
    - require:
      - file: archive-video.service
    - watch:
      - file: archive-video.service