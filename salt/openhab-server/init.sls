openhab:
  service.running:
    - enable: True
    - restart: True
    - require:
      - pkg: openhab-packages
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
    - name: deb https://openhab.jfrog.io/openhab/openhab-linuxpkg unstable main
    - file: /etc/apt/sources.list.d/openhab.list
    - humanname: openhab unstable repo
    - key: https://bintray.com/user/downloadSubjectPublicKey?username=openhab

openhab-packages:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs:
      - openjdk-11-jre-headless
      - postgresql-10
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
      - openhab
      - openhab-addons
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
  file.replace:
    - name: /etc/default/openhab
    - pattern: ^EXTRA_JAVA_OPTS=.*
    - repl: EXTRA_JAVA_OPTS="-Duser.timezone=Europe/Berlin"
    - append_if_not_found: true

openhab-dialout-group:
  group.present:
    - name: dialout
    - system: True
    - addusers:
      - openhab
    - require:
      - pkg: openhab-packages

ipcamera-binding:
  archive.extracted:
    - name: /usr/share/openhab/addons/
    - source: http://www.pcmus.com/openhab/IpCameraBinding/ipcamera-2020-03-19.zip
    - source_hash: 4ae0119a44d22567d5a78c55231ac358383e35c5 
    - enforce_toplevel: False

{% for directory in ['items', 'persistence', 'rules', 'services', 'sitemaps', 'things', 'transform'] %}
openhab-{{directory}}:
  file.recurse:
    - name: /etc/openhab/{{directory}}
    - source: salt://openhab-server/files/{{directory}}
    - include_empty: True
    - user: openhab
    - group: openhab
    - file_mode: 0644
    - template: jinja
    - clean: True
    - watch_in:
      - service: openhab
    - require:
      - pkg: openhab-packages
{% endfor %}

openhab-scripts:
  file.recurse:
    - name: /etc/openhab/scripts
    - source: salt://openhab-server/files/scripts
    - include_empty: True
    - user: openhab
    - group: openhab
    - file_mode: 0755
    - template: jinja
    - clean: True
    - watch_in:
      - service: openhab
    - require:
      - pkg: openhab-packages

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
    - name: /etc/openhab/habpanel
    - source: salt://openhab-server/files/habpanel
    - include_empty: True
    - user: openhab
    - group: openhab
    - file_mode: 0644
    - watch_in:
      - service: openhab

habpanel-css:
  file.managed:
    - name: /etc/openhab/html/habpanel.css
    - source: salt://openhab-server/files/habpanel/habpanel.css
    - makedirs: True
    - user: root
    - group: root

habpanel-configure-commands:
  service.running:
    - name: openhab
  cmd.script:
    - source: salt://openhab-server/files/habpanel/habpanel-setup.sh
    - onchanges:
      - file: habpanel-config
    - require:
      - cmd: openhab
      - file: habpanel-config

/var/lib/openhab/uuid:
  file.replace:
    - pattern: '^.*$'
    - repl: {{ salt['pillar.get']('openhab:uuid') }}

/var/lib/openhab/openhabcloud/secret:
  file.replace:
    - pattern: '^.*$'
    - repl: {{ salt['pillar.get']('openhab:openhabcloud-secret') }}

openhab-console-setup:
  cmd.script:
    - source: salt://openhab-server/files/scripts/console-setup.sh
    - require:
      - cmd: openhab

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