openhab-repo:
  pkgrepo.managed:
    - name: deb http://openhab.jfrog.io/openhab/openhab-linuxpkg unstable main
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

persistience-logging:
  file.append:
   - name: /var/lib/openhab2/etc/org.ops4j.pax.logging.cfg
   - text: | 
       # added by Saltstack
       log4j2.logger.org_openhab_persistence_jdbc.level = info
       log4j2.logger.org_openhab_persistence_jdbc.name = org.openhab.persistence.jdbc

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

add-habpanel-config: 
  file.managed:
    - name: /etc/openhab2/other-configs/habpanel-config.json
    - source: salt://openhab/files/other-configs/habpanel-config.json
    - makedirs: True
    - user: root
    - group: root

install-habpanel-config:
  service.running:
    - name: openhab2
  cmd.run:
    - onchanges:
      - file: /etc/openhab2/other-configs/habpanel-config.json
    - names:
      - echo "config:property-set -p org.openhab.habpanel panelsRegistry '$(cat /etc/openhab2/other-configs/habpanel-config.json | jq -ca . )' " | openhab-cli console -b -u openhab -p habopen
      - echo "config:property-set -p org.openhab.habpanel initialPanelConfig F17" | openhab-cli console -b -u openhab -p habopen

reset-openhab-db:
  cmd.run:
    - names:
      - echo "smarthome:inbox clear"  | openhab-cli console -b -u openhab -p habopen
      - echo "smarthome:things clear" | openhab-cli console -b -u openhab -p habopen
      - echo "smarthome:items clear"  | openhab-cli console -b -u openhab -p habopen
    - onchanges:
      - file: miio-binding
      - file: openhab-items
      - file: openhab-persistence
      - file: openhab-rules
      - file: openhab-services
      - file: openhab-sitemaps
      - file: openhab-things

openhab2:
  service.running:
    - enable: True
    - restart: True
    - require:
      - pkg: openhab-dependencies
    - onchanges:
      - file: miio-binding
      - file: openhab-items
      - file: openhab-persistence
      - file: openhab-rules
      - file: openhab-services
      - file: openhab-sitemaps
      - file: openhab-things
      