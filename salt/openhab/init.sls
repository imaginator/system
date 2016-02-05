openhab-get-archive:
  archive.extracted:
    - name: /opt/openhab
    - source: https://bintray.com/artifact/download/openhab/mvn/org/openhab/distro/openhab-offline/2.0.0.b1/openhab-offline-2.0.0.b1.zip
    - source_hash: https://bintray.com/artifact/download/openhab/mvn/org/openhab/distro/openhab-offline/2.0.0.b1/openhab-offline-2.0.0.b1.zip.md5
    - archive_format: zip

/opt/openhab/addons/org.openhab.ui.habmin.jar:
  file.managed:
    - source: https://github.com/cdjackson/HABmin2/releases/download/0.0.15/org.openhab.ui.habmin_2.0.0.SNAPSHOT-0.0.15.jar
    - source_hash: sha1=5d6f25de1b71b2e9800565ec333ac81d791ecba0

# habmin needs the zwave binding
openhab-habmin-zwave-binding:
  archive.extracted:
    - source: https://bintray.com/artifact/download/openhab/bin/distribution-1.8.0-addons.zip
    - source_hash: sha1=1f24a8610f094da6d55bd7177d995eea351aefc1
    - archive_format: zip
    - name: /tmp
  file.copy:
    - source: /tmp/addons_repo/org.openhab.binding.zwave-1.7.0.jar 
    - name: /opt/openhab/addons/org.openhab.binding.zwave-1.7.0.jar


/opt/openhab:
  file.directory:
    - user: simon
    - group: users
    - recurse:
      - user
      - group
    - require:
      - archive: openhab-get-archive
    
/opt/openhab/runtime/karaf/bin/karaf:
  file.managed:
    - mode: 755

/opt/openhab/start.sh:
  file.managed:
    - mode: 755


/etc/init/openhab.conf:
  file.managed:
    - source: salt://openhab/upstart-script
    - user: root
    - group: root
    - mode: 0755

openhab:
  service.running:
    - name: openhab
    - enable: True
    - force_reload: True
    - full_restart: True
    - require:
      - archive: openhab-get-archive

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
