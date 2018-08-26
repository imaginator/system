openhab-repo:
  pkgrepo.managed:
    - name: deb https://dl.bintray.com/openhab/apt-repo2 testing main
    - file: /etc/apt/sources.list.d/openhab.list
    - humanname: openhab2 repo
    - key: https://bintray.com/user/downloadSubjectPublicKey?username=openhab

openhab-dependencies:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs:
      - default-jre
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

#special permissions for watching the network
/usr/sbin/arping:
  file.managed:
    - mode: 4755
    - replace: False
    - require:
      - pkg: openhab-dependencies

postgres-user-openhab:
  postgres_user.present:
    - name: openhab
    - createdb: False
    - password: {{ salt['pillar.get']('openhab:db_password') }}

postgres-db-openhab:
  postgres_database.present:
    - name: openhab
    - user: postgres
    - encoding: UTF8
    - lc_ctype: en_US.UTF8
    - lc_collate: en_US.UTF8
    - template: template0
    - owner: openhab
    - require:
        - postgres_user: openhab

install-openhab:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs: 
      - openhab2
      - openhab2-addons
    - require:
      - pkg: openhab-dependencies
      - pkgrepo: openhab-repo

miio-binding:
  file.managed:
    - name: /usr/share/openhab2/addons/org.openhab.binding.miio-2.4.0-SNAPSHOT.jar
    - source: https://openhab.jfrog.io/openhab/libs-pullrequest-local/org/openhab/binding/org.openhab.binding.miio/2.4.0-SNAPSHOT/org.openhab.binding.miio-2.4.0-SNAPSHOT.jar
    - source_hash: "https://openhab.jfrog.io/openhab/libs-pullrequest-local/org/openhab/binding/org.openhab.binding.miio/2.4.0-SNAPSHOT/org.openhab.binding.miio-2.4.0-SNAPSHOT.jar.sha1"

ipcamera-binding:
  archive.extracted:
    - name: /usr/share/openhab2/addons/
    - source: http://www.pcmus.com/openhab/IpCameraBinding/ipcamera-26-07-2018.zip
    - source_hash: sha1=85f6a23284560255ef74bf5a0007ea55937553dd
    - enforce_toplevel: False

{% for directory in ['items', 'persistence', 'rules', 'services', 'sitemaps', 'things'] %}
openhab-{{directory}}:
  file.recurse:
    - name: /etc/openhab2/{{directory}}
    - source: salt://openhab/files/{{directory}}
    - include_empty: True
    - user: openhab
    - group: openhab
    - file_mode: 0644
    - template: jinja
    - watch_in:
      - service: openhab2
{% endfor %}

/etc/nginx/sites-enabled/openhab.imaginator.com.conf:
  file:
    - managed
    - user: root
    - group: root
    - source: salt://openhab/files/other-configs/nginx-openhab.conf

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

habpanel-console-config:
  file.managed:
    - name: /etc/openhab2/other-configs/console-setup.sh
    - source: salt://openhab/files/other-configs/console-setup.sh
    - makedirs: True
    - user: root
    - group: root

habpanel-config:
  file.managed:
    - name: /etc/openhab2/other-configs/habpanel-config.json
    - source: salt://openhab/files/other-configs/habpanel-config.json
    - makedirs: True
    - user: root
    - group: root

openhab2:
  service.running:
    - enable: True
    - restart: True
    - require:
      - pkg: openhab-dependencies
    - onchanges:
      - file: miio-binding
      - archive: ipcamera-binding
      - file: openhab-persistence
      - file: openhab-services
  cmd.run:
    - name: until nc -z localhost 8101; do sleep 1; done
    - timeout: 15

openhab-console-commands:
  cmd.script:
    - source: salt://openhab/files/other-configs/console-setup.sh
    - onchanges:
      - file: habpanel-console-config
    - require:
      - cmd: openhab2

habpanel-configure-commands:
  service.running:
    - name: openhab2
  cmd.script:
    - source: salt://openhab/files/other-configs/habpanel-setup.sh
    - onchanges:
      - file: habpanel-config
    - require:
      - cmd: openhab2

openhab-iptables-dhcp-accept-ipv4:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: udp
    - jump: accept-log
    - source: 0.0.0.0
    - dport: 6767
    - family: ipv4
    - match: comment 
    - comment: "DHCP accept"
    - save: true

weather-underground-icons:
  archive.extracted:
    - name: /etc/openhab2/html/weather-underground-icons
    - source: https://github.com/manifestinteractive/weather-underground-icons/archive/v1.0.1.tar.gz
    - user: openhab
    - group: openhab
    - if_missing: /etc/openhab2/html/weather-underground-icons
    - skip_verify: True 
    - options: "--strip=1"
    - enforce_toplevel: False
   
