motion:
  service.running:
    - enable: True
    - restart: True
    - onchanges:
      - file: /etc/motion/motion.conf
      - file: /etc/motion/timelapse.conf
    - require:
      - pkg: motion_pkgs
      - group: motion-in-plex
      - file: /srv/video/netcams

motion_pkgs:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs:
      - motion
      - ffmpeg

motion-in-plex:
  group.present:
    - name: motion
    - system: True
    - addusers:
      - plex

/srv/video/netcams:
  file.directory:
    - user: motion
    - group: plex
    - dir_mode: 755
    - recurse:
      - user
      - group
      - mode
    - require: 
      - group: motion-in-plex

/etc/motion/motion.conf:
  file:
    - managed
    - makedirs: true
    - user: motion
    - group: motion
    - source: salt://motion/files/motion.conf
    - template: jinja
    - require:
      - pkg: motion_pkgs

/etc/motion/timelapse.conf:
  file:
    - managed
    - makedirs: true
    - user: motion
    - group: motion
    - source: salt://motion/files/timelapse.conf
    - template: jinja
    - require:
      - pkg: motion_pkgs
