openhab:
  service.running:
    - enable: True
    - restart: True
    - require:
      - pkg: openhab-packages
      - postgres_database: openhab-database
      - file: openhab-java-opts
    - onchanges:
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
      - adb # tablet control
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

/usr/share/openhab/addons/org.openhab.binding.gruenbeckcloud.jar:
  file.managed:
    - source: https://cloud.familie-schoen.com/f/2cd5c4abe9/?dl=1
    - source_hash: 713e91da53cc854932531c44ab5edea882e20cea

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


openhab-remote-console:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: tcp
    - jump: ACCEPT
    - source: 10.7.8.0/22
    - dport: 8081
    - family: ipv4
    - match: comment 
    - comment: "Openhab Console Remote Access"
    - save: true

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
    - match: comment 
    - comment: "DHCP redirect for openhab"
    - save: True
