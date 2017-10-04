{% from "gmusicproxy/map.jinja" import gmusicproxy with context -%}

gmp-requirements-deps:
  pkg.installed:
    - names:
      - gcc
      - git
      - libffi-dev
      - libssl-dev
      - python-dev
      - python-pip
      - python-virtualenv

gmp-{{gmusicproxy.user}}:
  user.present:
    - fullname: Google Music Proxy Service
    - shell: /bin/false
    - home: {{ gmusicproxy.install_dir }}
    - createhome: False
    - gid: {{ gmusicproxy.group}}

gmp-install-dir:
  file.directory:
    - name: {{ gmusicproxy.install_dir }}
    - user: {{ gmusicproxy.user }}
    - group: {{ gmusicproxy.group }}
    - makedirs: True
    - recurse:
      - user
      - group

gmp-venv-dir:
  file.directory:
    - name: {{ gmusicproxy.virtualenv_dir }}
    - user: {{ gmusicproxy.user }}
    - group: {{ gmusicproxy.group }}
    - makedirs: True
    - recurse:
      - user
      - group

gmusicproxy:
  git.latest:
    - name: https://github.com/diraimondo/gmusicproxy.git
    - target: {{ gmusicproxy.install_dir }}
    - user: {{ gmusicproxy.user }}
    - require:
      - file: gmp-install-dir
      - pkg: gmp-requirements-deps
  virtualenv.managed:
    - name: {{ gmusicproxy.virtualenv_dir }}
    - no_chown: True
    - requirements: {{ gmusicproxy.install_dir }}/requirements.txt
    - use_wheel: True
    - cwd:  {{ gmusicproxy.install_dir }}
    - user: {{ gmusicproxy.user }}
    - env_vars:
        LC_ALL: utf-8
    - require:
      - pkg: gmp-requirements-deps
  pip.installed:
    - editable: {{ gmusicproxy.install_dir }}
    - bin_env: {{ gmusicproxy.virtualenv_dir }}
    - user: {{ gmusicproxy.user }}
    - use_wheel: True
    - require:
      - virtualenv: gmusicproxy

gmp-service-definition:
  file.managed:
    - name: /lib/systemd/system/gmusicproxy.service
    - source: salt://gmusicproxy/files/systemd.service.jinja
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - require:
      - user: gmusicproxy-user
      - group: gmusicproxy-user

gmp-config:
  file.managed:
    - name: {{ gmusicproxy.virtualenv_dir }}/gmusicproxy.config
    - source: salt://gmusicproxy/files/gmusicproxy.config.jinja
    - user: {{ gmusicproxy.user }}
    - group: {{ gmusicproxy.group }}
    - mode: 600
    - template: jinja
    - require:
      - user: gmusicproxy-user
      - group: gmusicproxy-user

gmusicproxy-service:
  pip.installed:
    - names:
      - gunicorn
      - trollius
    - bin_env: {{ gmusicproxy.virtualenv_dir }}
    - user: {{ gmusicproxy.user }}
    - use_wheel: True
    - require:
      - virtualenv: gmusicproxy
  service.enabled:
    - name: gmusicproxy
    - require:
      - file: gmp-service-definition

{{ gmusicproxy.user_config_dir }}/gmusicapi:
  file.directory:
    - user: {{ gmusicproxy.user }}
    - group: {{ gmusicproxy.group }}
    - makedirs: True
    - recurse:
      - user
      - group

gmusicproxy-user:
  user.present:
    - name: {{ gmusicproxy.user }}
    - groups:
      - {{ gmusicproxy.group }}
  group.present:
    - name: {{ gmusicproxy.group }}


