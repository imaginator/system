transmission-daemon:
  service.running:
    - enable: True
    - require:
      - pkg: install-transmission
      - file: transmission-dirs
      - file: /etc/transmission-daemon/settings.json
      - file: /lib/systemd/system/transmission-daemon.service
    - watch:
      - file: /etc/transmission-daemon/settings.json
      - file: /lib/systemd/system/transmission-daemon.service
  file.managed:
    - name: /lib/systemd/system/transmission-daemon.service
    - source: salt://transmission/files/transmission-daemon.service
    - user: root
    - group: root
    - mode: 644
  module.run:
    - name: service.systemctl_reload
    - onchanges:
      - file: /lib/systemd/system/transmission-daemon.service

media:
  group.present:
    - system: True
    - members:
      - simon
      - ryan
      - debian-transmission
      - www-data

install-transmission:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs:
      - transmission-daemon
      - transmission-cli

transmission-dirs:
  file.directory:
    - makedirs: true
    - user: debian-transmission
    - group: media
    - dir_mode: 755
    - mode: 644
    - recurse:
      - user
      - group
      - mode
    - names:
        - /var/tmp/transmission/in-progress
        - /srv/video/Complete

/etc/transmission-daemon/settings.json:
  file.managed:
    - user: debian-transmission
    - group: debian-transmission
    - mode: 644
    - source: salt://transmission/files/settings.json
    - require:
      - pkg: install-transmission

/etc/nginx/sites.enabled/transmission.imagilan.conf:
  file:
    - managed
    - makedirs: true
    - user: root
    - group: root
    - source: salt://transmission/files/nginx.conf
    - require:
      - pkg: install-transmission

transmissionweb-ipv4-iptables:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: tcp
    - jump: ACCEPT
    - source: 10.7.10.0/23
    - dport: 9091
    - family: ipv4
    - match: comment 
    - comment: "transmissionweb input"
    - save: true

net.core.rmem_max:
  sysctl.present:
    - value: 16777216

net.core.wmem_max:
  sysctl.present:
  - value: 4194304