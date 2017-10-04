{% from "gmusicprocurator/map.jinja" import gmusicprocurator with context -%}
{{ gmusicprocurator.user_config_dir }}/gmusicapi:
  file.directory:
    - user: {{ gmusicprocurator.user }}
    - group: {{ gmusicprocurator.group }}
    - makedirs: True
    - recurse:
      - user
      - group
