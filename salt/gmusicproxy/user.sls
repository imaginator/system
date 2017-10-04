{% from "gmusicprocurator/map.jinja" import gmusicprocurator with context -%}
gmusicprocurator-user:
  user.present:
    - name: {{ gmusicprocurator.user }}
    - groups:
      - {{ gmusicprocurator.group }}
  group.present:
    - name: {{ gmusicprocurator.group }}
