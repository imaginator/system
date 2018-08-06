samba-packages:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs:
      - smbclient
      - samba

samba-config:
    file.managed:
        - name: /etc/samba/smbd.conf
        - source: salt://samba/files/smbd.conf
        - template: Jinja

samba-service:
  service.running:
    - name: samba
    - enable: True
    - require:
      - pkg: samba-packages
    - watch:
      - file: samba-config



