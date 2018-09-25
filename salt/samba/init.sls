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

samba-service:
  service.running:
    - name: smbd
    - enable: True
    - reload: True
    - require:
      - pkg: samba-packages
    - watch:
      - file: samba-config
