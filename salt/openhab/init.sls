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

#special permissions for watching the network
/usr/sbin/arping:
  file.managed:
    - mode: 4755
    - replace: False
    - depends:
      - pkg: iputils-arping

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
   - depends:
    - pkg: iputils-arping
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

#openhab-remove-cache-tmp:
#  service.dead:
#    - name: openhab2
#  file.directory:
#    - names: 
#      - /var/lib/openhab2/cache/
#      - /var/lib/openhab2/config/
#      - /var/lib/openhab2/jsondb/
#      - /var/lib/openhab2/kar/
#      - /var/lib/openhab2/persistence/
#      - /var/lib/openhab2/voicerss/
#    - clean: True
#    - require:
#      - pkg: install-openhab

/etc/nginx/sites-enabled/openhab.imaginator.com.conf:
  file:
    - managed
    - user: root
    - group: root
    - source: salt://openhab/files/other-configs/nginx-openhab.conf

openhab-webaccess:
  webutil.user_exists:
    - name: simon
    - password: {{ salt['pillar.get']('openhab:htaccess_password') }}
    - htpasswd_file: /etc/nginx/htpasswd
    - options: s

openhab2:
  service.running:
    - enable: True
    - require:
      - pkg: openhab-dependencies
    - watch:
      - file: miio-binding