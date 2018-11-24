samba-packages:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs:
      - smbclient
      - samba

samba-config:
    file.managed:
      - name: /etc/samba/smb.conf
      - source: salt://samba/files/smb.conf
      - makedirs: true
      - user: root
      - group: root
      - mode: 0644

samba-service:
  service.running:
    - name: smbd
    - enable: True
    - reload: True
    - require:
      - pkg: samba-packages
    - watch:
      - file: samba-config

samba-iptables-accept-ipv4-tcp:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: tcp
    - jump: accept-log
    - source: 10.7.10.0/23
    - dport: 445
    - family: ipv4
    - match: comment 
    - comment: "Samba TCP"
    - save: true

samba-iptables-accept-ipv4-udp:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: udp
    - jump: accept-log
    - source: 10.7.10.0/23
    - dport: 445
    - family: ipv4
    - match: comment 
    - comment: "Samba UDP"
    - save: true

