# vim: ft=sls

smartmontools_pkg:
  pkg.installed:
    - name: smartmontools

smartmontools_default_config:
  file.managed:
    - name: '/etc/default/smartmontools'
    - source: salt://smartmontools/files/default_smartmontools.j2
    - user: root
    - group : root
    - mode: 0644
    - template: jinja

