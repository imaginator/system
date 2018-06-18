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

simon.sudo:
  file.managed:
    - user: root
    - group: root
    - mode: 0440
    - source: salt://users/files/simon.sudoers
    - name: /etc/sudoers.d/simon
    - check_cmd: /usr/sbin/visudo -c -f

remove-default-user-accounts: 
  user.absent:
    - name: pi
    - require:
      - user: simon
      - file: /etc/sudoers.d/simon
