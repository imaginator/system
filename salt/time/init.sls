no-ntp:
  pkg.purged:
    - name: ntp

chrony:
  pkg.installed:
    - name: chrony  
  service.running:
    - enable: True
    - name: chrony
    - require:
      - pkg: chrony

