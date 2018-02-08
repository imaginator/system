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
      - openjdk-8-jre-headless
      - postgresql
      - apache2-utils
      - mosquitto
      - mosquitto-clients
      - nginx-full

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

#openhab-remove-cruft:
#  service.dead:
#    - name: openhab2
#  file.absent:
#    - names: 
#      - /var/lib/openhab2/uuid
#      - /var/lib/openhab2/.karaf

mii-binding:
  file.managed:
    - name: /usr/share/openhab2/addons/org.openhab.binding.miio-2.2.0-SNAPSHOT.jar
    - source: https://openhab.jfrog.io/openhab/libs-pullrequest-local/org/openhab/binding/org.openhab.binding.miio/2.2.0-SNAPSHOT/org.openhab.binding.miio-2.2.0-SNAPSHOT.jar
    - source_hash: "https://openhab.jfrog.io/openhab/libs-pullrequest-local/org/openhab/binding/org.openhab.binding.miio/2.2.0-SNAPSHOT/org.openhab.binding.miio-2.2.0-SNAPSHOT.jar.sha1"

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

/etc/openhab2/things/all.things:
  file.managed:
    - source: salt://openhab/files/things/all.things
    - user: openhab
    - group: openhab
    - mode: 0644
    - template: jinja

openhab-items:
  file.recurse:
    - name: /etc/openhab2/items
    - source: salt://openhab/files/items
    - include_empty: True
    - user: openhab
    - group: openhab
    - file_mode: 0644

openhab-rules:
  file.recurse:
    - name: /etc/openhab2/rules
    - source: salt://openhab/files/rules
    - include_empty: True
    - user: openhab
    - group: openhab
    - file_mode: 0644

openhab-persistence:
  file.recurse:
    - name: /etc/openhab2/persistence
    - source: salt://openhab/files/persistence
    - include_empty: True
    - user: openhab
    - group: openhab
    - file_mode: 0644

/etc/openhab2/services/addons.cfg:
  file.managed:
    - source: salt://openhab/files/services/addons.cfg
    - user: openhab
    - group: openhab
    - mode: 0644

/etc/openhab2/services/habpanel.cfg:
  file.managed:
    - source: salt://openhab/files/services/habpanel.cfg
    - user: openhab
    - group: openhab
    - mode: 0644

/etc/openhab2/services/network.cfg:
  file.managed:
    - source: salt://openhab/files/services/network.cfg
    - user: openhab
    - group: openhab
    - mode: 0644

/etc/openhab2/services/runtime.cfg:
  file.managed:
    - source: salt://openhab/files/services/runtime.cfg
    - user: openhab
    - group: openhab
    - mode: 0644

/etc/openhab2/services/chromecast.cfg:
  file.managed:
    - source: salt://openhab/files/services/chromecast.cfg
    - user: openhab
    - group: openhab
    - mode: 0644

/etc/openhab2/services/plex.cfg:
  file.managed:
    - source: salt://openhab/files/services/plex.cfg
    - user: openhab
    - group: openhab
    - mode: 0644
    - template: jinja

/etc/openhab2/services/jdbc.cfg:
  file.managed:
    - source: salt://openhab/files/other-configs/jdbc.cfg.jinja
    - user: openhab
    - group: openhab
    - mode: 0644
    - template: jinja

persistience-logging:
  file.append:
   - name: /var/lib/openhab2/etc/org.ops4j.pax.logging.cfg
   - text: | 
       # added by Saltstack
       log4j2.logger.org_openhab_persistence_jdbc.level = info
       log4j2.logger.org_openhab_persistence_jdbc.name = org.openhab.persistence.jdbc

# Network presence
iputils-arping:
  pkg.installed

/usr/sbin/arping:
  file.managed:
    - mode: 4755
    - replace: False
    - depends:
      - pkg: iputils-arping

openhab2:
  service.running:
    - enable: True
    - require:
      - pkg: openhab-dependencies
    - watch:
      - file: mii-binding
      - file: /etc/openhab2/things/all.things
      - file: openhab-items
      - file: openhab-rules
      - file: /etc/openhab2/*


# vim:ft=yaml:
