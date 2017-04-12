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
      - file: /etc/openhab2/items/*
      - file: /etc/openhab2/persistence/*
      - file: /etc/openhab2/services/*
      - file: /etc/openhab2/things/*

/etc/openhab2/services/jdbc.cfg:
  file.managed:
    - source: salt://openhab/jdbc.cfg.jinja
    - user: openhab
    - group: openhab
    - mode: 0644
    - template: jinja

/etc/openhab2/persistence/postgresql.persist:
  file.managed:
    - source: salt://openhab/postgresql.persist
    - user: openhab
    - group: openhab
    - mode: 0644

/etc/openhab2/services/plex.cfg:
  file.managed:
    - source: salt://openhab/plex.cfg.jinja
    - user: openhab
    - group: openhab
    - mode: 0644
    - template: jinja

/etc/openhab2/items/imagihouse.items:
  file.managed:
    - source: salt://openhab/imagihouse.items
    - user: openhab
    - group: openhab
    - mode: 0644

/etc/openhab2/things/imagihouse.things:
  file.managed:
    - source: salt://openhab/imagihouse.things
    - user: openhab
    - group: openhab
    - mode: 0644

/etc/nginx/conf.d/nginx-openhab.conf:
  file:
    - managed
    - makedirs: true
    - user: root
    - group: root
    - source: salt://openhab/nginx-openhab.conf

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
