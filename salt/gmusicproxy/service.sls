{% from "gmusicprocurator/map.jinja" import gmusicprocurator with context -%}
{% if gmusicprocurator.use_service -%}
gmp-service-definition:
  file.managed:
{%- if gmusicprocurator.use_systemd %}
    - name: /lib/systemd/system/gmusicprocurator.service
    - source: salt://gmusicprocurator/files/systemd.service.jinja
{%- elif gmusicprocurator.use_sysvinit %}
    - name: /etc/init.d/gmusicprocurator
    - source: salt://gmusicprocurator/files/sysvinit/init.d.jinja
{%- endif %}
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
{%- for variable in ['log_file', 'pid_file', 'service_config_dir', 'service_host', 'service_port', 'user', 'virtualenv_dir'] %}
        {{ variable }}: {{ gmusicprocurator[variable] }}
{%- endfor %}
    - require:
      - user: gmusicprocurator-user
      - group: gmusicprocurator-user

{% if gmusicprocurator.use_sysvinit -%}
gmp-service-config:
  file.managed:
    - name: /etc/default/gmusicprocurator
    - source: salt://gmusicprocurator/files/sysvinit/default.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - context:
        service_config_dir: {{ gmusicprocurator.service_config_dir }}
    - require:
      - user: gmusicprocurator-user
      - group: gmusicprocurator-user
{% endif -%}
{% endif %}

gmusicprocurator-service:
  pip.installed:
    - names:
      - gunicorn
      - trollius
    - bin_env: {{ gmusicprocurator.virtualenv_dir }}
    - user: {{ gmusicprocurator.user }}
{%- if gmusicprocurator.use_wheels %}{# requires pip >= 1.4 #}
    - use_wheel: True
{%- endif %}
    - require:
      - virtualenv: gmusicprocurator
  service.enabled:
    - name: gmusicprocurator
    - require:
      - file: gmp-service-definition
