# vim: ft=sls
#

{% set smartmontools = salt['pillar.get'](
        'smartmontools',
        default=default_settings.smartmontools,
        merge=True
    )
%}

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

smartmontools_smartd_config:
  file.managed:
    - name: '/etc/smartd.conf'
    - source: salt://smartmontools/files/smartd.conf.j2
    - user: root
    - group : root
    - mode: 0644
    - template: jinja

smartmontools_service:
 service.{{ smartmontools.service.state }}:
   - name: {{ smartmontools.service.name }}
   - enable: {{ smartmontools.service.enable }}
   - watch:
       - file: smartmontools_default_config
       - file: smartmontools_smartd_config


