{% for name, user in pillar.get('users', {}).items() %}
{{name}}:
  user.{{user.state}}:
  {% if user.state == 'present' %}
    - fullname: {{user.fullname}}
    - shell: {{user.shell}}
    - home: {{user.home}}
    - createhome: True
    - groups: {{user.groups}}
    - remove_groups: False
ssh_key_{{name}}:
  ssh_auth:
    - present
    - user: {{name}}
    - names: 
      - {{user.pubkey}}
    - require:
      - user: {{ name }}
  {% elif user.state == 'absent' %}
    - purge: {{user.purge}}
  {% endif %}
{% endfor %}

/etc/sudoers.d/simon:
  file.managed:
    - user: root
    - group: root
    - mode: 0440
    - source: salt://users/files/simon.sudoers
    - check_cmd: /usr/sbin/visudo -c -f

{%- if salt['user.info']('pi') %}
remove-pi-user:
  user.absent:
    - name: pi
    - force: True
    - require:
      - user: simon
      - file: /etc/sudoers.d/simon
{%- endif %}
