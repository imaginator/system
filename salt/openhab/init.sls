openhab-repo:
  pkgrepo.managed:
    - name: deb http://openhab.jfrog.io/openhab/openhab-linuxpkg unstable main
    - file: /etc/apt/sources.list.d/openhab.list
    - humanname: openhab2 repo
    - key: https://bintray.com/user/downloadSubjectPublicKey?username=openhab

openhab-dependencies:
  pkg.installed:
    - pkgs:
      - openhab2-addons
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
    - user: openhab
    - encoding: UTF8
    - lc_ctype: en_US.UTF8
    - lc_collate: en_US.UTF8
    - template: template0
    - owner: openhab
    - require:
        - postgres_user: openhab

openhab-remove-cruft:
  service.dead:
    - name: openhab2
  file.absent:
    - names: 
      - /var/lib/openhab2/cache
      - /var/lib/openhab2/config
      - /var/lib/openhab2/jasondb
      - /var/lib/openhab2/kar
      - /var/lib/openhab2/log
      - /var/lib/openhab2/persistence
      - /var/lib/openhab2/uuid
      - /var/lib/openhab2/voicerss
      - /var/lib/openhab2/.karaf

openhab:
  pkg.installed:
    - name: openhab2
    - name: openhab2-addons
  service.running:
    - name: openhab2
    - enable: True
    - require:
      - pkg: openhab-dependencies
    - watch:
      - file: weather-icons
      - file: /etc/openhab2/items/*
      - file: /etc/openhab2/persistence/*
      - file: /etc/openhab2/services/*
      - file: /etc/openhab2/rules/*
      - file: /etc/openhab2/things/*
      - file: /var/lib/openhab2/etc/org.eclipse.smarthome.basicui.cfg

/etc/openhab2/services/addons.cfg:
  file.managed:
    - source: salt://openhab/files/addons.cfg
    - user: openhab
    - group: openhab
    - mode: 0644

weather-icons:
  file.managed:
    - name: /usr/share/openhab2/addons/org.openhab.ui.iconset.climacons.jar
    - source: https://github.com/ghys/org.openhab.ui.iconset.climacons/releases/download/2.2.0.201707061209/org.openhab.ui.iconset.climacons-2.2.0-SNAPSHOT.jar
    - source_hash: sha256=81c8ef48c7cbfb37a9b1409314720490385b94fc360971dbd25d2097877e530f


/etc/openhab2/services/jdbc.cfg:
  file.managed:
    - source: salt://openhab/files/jdbc.cfg.jinja
    - user: openhab
    - group: openhab
    - mode: 0644
    - template: jinja

/etc/openhab2/persistence/postgresql.persist:
  file.managed:
    - source: salt://openhab/files/postgresql.persist
    - user: openhab
    - group: openhab
    - mode: 0644

/etc/openhab2/rules/imagihouse.rules:
  file.managed:
    - source: salt://openhab/files/imagihouse.rules
    - user: openhab
    - group: openhab
    - mode: 0644

/etc/openhab2/services/runtime.cfg:
  file.managed:
    - source: salt://openhab/files/runtime.cfg
    - user: openhab
    - group: openhab
    - mode: 0644

/etc/openhab2/services/services.cfg:
  file.managed:
    - source: salt://openhab/files/services.cfg
    - user: openhab
    - group: openhab
    - mode: 0644

/etc/openhab2/services/plex.cfg:
  file.managed:
    - source: salt://openhab/files/plex.cfg.jinja
    - user: openhab
    - group: openhab
    - mode: 0644
    - template: jinja

/etc/openhab2/items/imagihouse.items:
  file.managed:
    - source: salt://openhab/files/imagihouse.items
    - user: openhab
    - group: openhab
    - mode: 0644

/etc/openhab2/things/imagihouse.things:
  file.managed:
    - source: salt://openhab/files/imagihouse.things
    - user: openhab
    - group: openhab
    - mode: 0644

imagihouse-sitemap:
  file.replace:
   - name: /var/lib/openhab2/etc/org.eclipse.smarthome.basicui.cfg
   - pattern: "defaultSitemap.*"
   - repl: "defaultSitemap = imagihouse"
   - append_if_not_found: true
   - show_changes: true

/etc/nginx/conf.d/nginx-openhab.conf:
  file:
    - managed
    - makedirs: true
    - user: root
    - group: root
    - source: salt://openhab/files/nginx-openhab.conf

openhab-webaccess:
  webutil.user_exists:
    - name: simon
    - password: {{ salt['pillar.get']('openhab:htaccess_password') }}
    - htpasswd_file: /etc/nginx/htpasswd
    - options: d
    - force: true

openhab_iptables-tcp:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: tcp
    - jump: accept-log
    - dports: 32400
    - family: ipv4
    - match: comment 
    - comment: openhab-web-tcp
    - save: true

openhab_iptables-udp:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: udp
    - jump: accept-log
    - dports: 32400
    - family: ipv4
    - match: comment 
    - comment: openhab-udp
    - save: true

openhab_iptables-bonjour:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: udp
    - jump: accept-log
    - dports: 5353
    - family: ipv4
    - match: comment 
    - comment: openhab-web-udp
    - save: true

openhab2-firewall-ipv4:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: accept-log
    - match: 
      - state
      - comment
    - comment: "OpenHAB"
    - connstate: NEW
    - dport: 8080
    - source: '0.0.0.0/0'
    - proto: tcp
    - save: true
