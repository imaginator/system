openhab2:
  service.running:
    - enable: True
    - restart: True
    - require:
      - pkg: openhab-packages
      - file: spotify-binding
      - archive: ipcamera-binding
      - postgres_database: openhab-database
      - file: openhab-java-opts
    - onchanges:
      - archive: ipcamera-binding
      - file: openhab-persistence
      - file: openhab-java-opts
      - file: openhab-services
  cmd.run:
    - name: until nc -z localhost 8101; do sleep 1; done
    - timeout: 15

openhab-repo:
  pkgrepo.managed:
    - name: deb https://dl.bintray.com/openhab/apt-repo2 stable main
    - file: /etc/apt/sources.list.d/openhab.list
    - humanname: openhab2 repo
    - key: https://bintray.com/user/downloadSubjectPublicKey?username=openhab

openhab-packages:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs:
      - openjdk-8-jre-headless # https://www.openhab.org/docs/installation/#prerequisites
      - postgresql
      - apache2-utils
      - mosquitto
      - mosquitto-clients
      - nginx-full
      - libpulse-jni
      - libpulse-java
      - iputils-arping
      - android-tools-adb # tablet control
      - jq
      - npm               # weatherunderground icons
      - openhab2
      - openhab2-addons
    - require:
      - openhab-repo

#special permissions for watching the network
/usr/sbin/arping:
  file.managed:
    - mode: 4755
    - replace: False
    - require:
      - pkg: openhab-packages

openhab-database-user:
  postgres_user.present:
    - name: openhab
    - createdb: False
    - password: {{ salt['pillar.get']('openhab:db_password') }}

openhab-database:
  postgres_database.present:
    - name: openhab
    - user: postgres
    - encoding: UTF8
    - lc_ctype: en_US.UTF8
    - lc_collate: en_US.UTF8
    - template: template0
    - owner: openhab
    - require:
        - postgres_user: openhab-database-user

openhab-java-opts:
  file.line:
    - name: /etc/default/openhab2
    - mode: ensure
    - content: EXTRA_JAVA_OPTS="-Duser.timezone=Europe/Berlin"
    - after: EXTRA_JAVA_OPTS=.*

openhab-dialout-group:
  group.present:
    - name: dialout
    - system: True
    - addusers:
      - openhab
    - require:
      - pkg: openhab-packages

spotify-binding:
  file.managed:
    - name: /usr/share/openhab2/addons/org.openhab.binding.spotify.jar
    - source: https://github.com/Hilbrand/openhab2-addons/releases/download/spotify/org.openhab.binding.spotify-2.4.0-SNAPSHOT.jar
    - source_hash: cd5d4c87453315d3e945ea9bfc2d4467bf543791 

ipcamera-binding:
  archive.extracted:
    - name: /usr/share/openhab2/addons/
    - source: http://www.pcmus.com/openhab/IpCameraBinding/ipcamera-12-01-2019.zip
    - source_hash: 639c29f1b549a968105eb2ccb1fb22344c6df623 
    - enforce_toplevel: False

{% for directory in ['items', 'persistence', 'rules', 'services', 'sitemaps', 'things', 'transform'] %}
openhab-{{directory}}:
  file.recurse:
    - name: /etc/openhab2/{{directory}}
    - source: salt://openhab-server/files/{{directory}}
    - include_empty: True
    - user: openhab
    - group: openhab
    - file_mode: 0644
    - template: jinja
    - watch_in:
      - service: openhab2
    - require:
      - pkg: openhab-packages
{% endfor %}

/etc/nginx/sites-enabled/openhab.imaginator.com.conf:
  file:
    - managed
    - user: root
    - group: root
    - source: salt://openhab-server/files/other-configs/nginx-openhab.conf

openhab-cert:
  acme.cert:
    - name: openhab.imaginator.com
    - email: simon@imaginator.com
    - webroot: /var/www/letsencrypt
    - renew: 14
    - owner: root
    - group: certificates

openhab-webaccess:
  webutil.user_exists:
    - name: simon
    - password: {{ salt['pillar.get']('openhab:htaccess_password') }}
    - htpasswd_file: /etc/nginx/htpasswd
    - options: s

# Habpanel

habpanel-config:
  file.recurse:
    - name: /etc/openhab2/habpanel
    - source: salt://openhab-server/files/habpanel
    - include_empty: True
    - user: openhab
    - group: openhab
    - file_mode: 0644
    - watch_in:
      - service: openhab2

habpanel-css:
  file.managed:
    - name: /etc/openhab2/html/habpanel.css
    - source: salt://openhab-server/files/habpanel/habpanel.css
    - makedirs: True
    - user: root
    - group: root

habpanel-configure-commands:
  service.running:
    - name: openhab2
  cmd.script:
    - source: salt://openhab-server/files/habpanel/habpanel-setup.sh
    - onchanges:
      - file: habpanel-config
    - require:
      - cmd: openhab2
      - file: habpanel-config

openhab-console-setup-script:
  file.managed:
    - name: /etc/openhab2/other-configs/console-setup.sh
    - source: salt://openhab-server/files/other-configs/console-setup.sh
    - makedirs: True
    - user: root
    - group: root

openhab-console-setup:
  cmd.script:
    - source: salt://openhab-server/files/other-configs/console-setup.sh
    - require:
      - cmd: openhab2

openhab-iptables-dhcp-accept-ipv4:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: udp
    - jump: ACCEPT
    - source: 0.0.0.0
    - dport: 67
    - family: ipv4
    - match: comment 
    - comment: "DHCP accept for openhab"
    - save: true

openhab-iptables-dhcp-redirect-ipv4:
  iptables.append:
    - chain: PREROUTING
    - table: nat
    - in-interface: trusted
    - proto: udp
    - dport: 67
    - jump: REDIRECT
    - to-port: 6767
    - destination: 127.0.0.1
    - comment: "DHCP redirect for openhab"
    - save: True

mosquitto-ipv4-iptables:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: tcp
    - jump: ACCEPT
    - source: 10.7.11.0/24
    - dport: 1883
    - family: ipv4
    - match: comment 
    - comment: "mosquitto input"
    - save: true