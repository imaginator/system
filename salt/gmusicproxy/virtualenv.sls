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
{%- if gmusicproxy.frontend_enabled %}
{%- from 'node/map.jinja' import npm_requirement with context %}
  npm.bootstrap:
    - name: {{ gmusicproxy.install_dir }}
    - user: {{ gmusicproxy.user }}
    - require:
      - {{ npm_requirement }}
      - git: gmusicproxy
  cmd.run:
    - name: node_modules/.bin/bower install
    - user: {{ gmusicproxy.user }}
    - cwd: {{ gmusicproxy.install_dir }}
    - require:
      - npm: gmp-requirements-deps
{%- endif %}

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
    - name: https://github.com/malept/gmusicproxy.git
    - target: {{ gmusicproxy.install_dir }}
    - user: {{ gmusicproxy.user }}
    - require:
      - file: gmp-install-dir
      - pkg: gmp-requirements-deps
  virtualenv.managed:
    - name: {{ gmusicproxy.virtualenv_dir }}
    # The following directive fixes relative dirs for requirements*.txt for some reason
    - no_chown: True
{%- if gmusicproxy.frontend_enabled %}
    - requirements: {{ gmusicproxy.install_dir }}/requirements/formula-frontend.txt
{%- else %}
    - requirements: {{ gmusicproxy.install_dir }}/requirements/base.txt
{%- endif %}
{%- if gmusicproxy.use_wheels %}{# requires pip >= 1.4 #}
    - use_wheel: True
{%- endif %}
    - user: {{ gmusicproxy.user }}
    - require:
      - pkg: gmp-requirements-deps
{%- if gmusicproxy.frontend_enabled %}
      - cmd: gmp-requirements-deps
      - git: gmusicproxy
      - file: gmp-venv-dir
{%- endif %}
  pip.installed:
    - editable: {{ gmusicproxy.install_dir }}
    - bin_env: {{ gmusicproxy.virtualenv_dir }}
    - user: {{ gmusicproxy.user }}
{%- if gmusicproxy.use_wheels %}{# requires pip >= 1.4 #}
    - use_wheel: True
{%- endif %}
    - require:
      - virtualenv: gmusicproxy
