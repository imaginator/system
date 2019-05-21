media:
  group.present:
    - system: True
    - members:
      - simon
      - ryan
      - debian-deluged
      - www-data

install-deluge:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs:
      - deluge
      - deluged
      - deluge-web

deluge-dirs:
  file.directory:
    - makedirs: true
    - user: debian-deluged
    - group: media
    - dir_mode: 755
    - file_mode: 644
    - recurse:
      - user
      - group
      - mode
    - names:
        - /etc/deluge
        - /var/tmp/deluge/in-progress
        - /srv/video/Complete

/var/tmp/deluge:
  file.directory:
    - makedirs: true
    - user: debian-deluged
    - group: media
    - dir_mode: 755
    - file_mode: 644
    - recurse:
      - user
      - group
      - mode

/etc/deluge/core.conf:
  file.managed:
    - user: debian-deluged
    - group: media
    - source: salt://deluge/files/core.conf
    - require:
      - pkg: install-deluge

deluge:
  file.managed:
    - name: /etc/systemd/system/deluge.service
    - source: salt://deluge/files/deluge.service
    - user: root
    - group: root
    - mode: 644
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: deluge
  service.running:
    - enable: True
    - require:
      - file: deluge
      - file: /etc/deluge/core.conf
    - watch:
      - file: deluge

delugeweb:
  file.managed:
    - name: /etc/systemd/system/delugeweb.service
    - source: salt://deluge/files/delugeweb.service
    - user: root
    - group: root
    - mode: 644
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: delugeweb
  service.running:
    - enable: True
    - require:
      - file: deluge
      - file: /etc/deluge/core.conf
    - watch:
      - file: delugeweb

delugeweb-ipv4-iptables:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: tcp
    - jump: ACCEPT
    - source: 10.7.10.0/23
    - dport: 8112
    - family: ipv4
    - match: comment 
    - comment: "delugeweb input"
    - save: true
