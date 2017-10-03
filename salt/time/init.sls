no-ntp:
  pkg.purged:
    - name: ntp

chrony:
  pkg.installed:
    - names: 
      - chrony
      - ntpdate  
  service.running:
    - enable: True
    - name: chrony
    - require:
      - pkg: chrony

timezone_setting:
  timezone.system:
    - name: Etc/UTC
    - utc: True

