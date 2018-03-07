pulseaudio-dlna-repo:        
  pkgrepo.managed:        
    - human_name: Pulseaudio-DLNA PPA
    - ppa: qos/pulseaudio-dlna

pulseaudio-dlna-dependencies:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs:
      - python-pyroute2
      - python-zeroconf
      - python-chardet
      - python-psutil
      - python-protobuf
      - python-notify2

install-pulseaudio-dlna:
  pkg.installed:
    - name: pulseaudio-dlna
    - cache_valid_time: 30000
    - require:        
      - pkgrepo: pulseaudio-dlna-repo
      - pkg: pulseaudio-dlna-dependencies

/etc/pulse/system.pa:
  file.managed:
    - user: root
    - group: root
    - source: salt://pulseaudio/files/system.pa

/etc/pulse/daemon.conf:
  file.managed:
    - user: root
    - group: root
    - source: salt://pulseaudio/files/daemon.conf

/etc/pulse/client.conf:
  file.managed:
    - user: root
    - group: root
    - source: salt://pulseaudio/files/client.conf

/etc/pulseaudio-dlna/devices.json:
  file.managed:
    - user: root
    - group: root
    - makedirs: true
    - source: salt://pulseaudio/files/devices.json

/etc/pulse/default.pa:
  file.absent

/etc/systemd/system/pulseaudio.service:
  file.managed:
    - user: root
    - group: root
    - source: salt://pulseaudio/files/pulseaudio.service

# pulseaudio-dlna runs as the pulse user
pulse-access:
  group.present:
    - addusers:
      - pulse

/etc/systemd/system/pulseaudio-dlna.service:
  file:
    - managed
    - user: root
    - group: root
    - source: salt://pulseaudio/files/pulseaudio-dlna.service

pulseaudio:
  service.running:
    - enable: True
    - require:
      - pkg: pulseaudio-dlna-dependencies
      - file: /etc/systemd/system/pulseaudio.service
      - file: /etc/pulse/system.pa
      - file: /etc/pulse/default.pa
      - file: /etc/pulse/client.conf
      - file: /etc/pulse/daemon.conf
    - watch:
      - file: /etc/systemd/system/pulseaudio.service
      - file: /etc/pulse/system.pa
      - file: /etc/pulse/default.pa
      - file: /etc/pulse/client.conf
      - file: /etc/pulse/daemon.conf

pulseaudio-dlna:
  service.running:
    - enable: True
    - require:
      - pkg: pulseaudio-dlna-dependencies
      - pkg: pulseaudio-dlna
      - file: /etc/pulseaudio-dlna/devices.json
    - watch:
      - file: /etc/pulseaudio-dlna/devices.json
      - file: /etc/systemd/system/pulseaudio.service
      - file: /etc/systemd/system/pulseaudio-dlna.service

# vim:ft=yaml:
