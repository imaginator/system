prosody-repo:
  pkgrepo.managed:
   - name: deb http://packages.prosody.im/debian trusty main
   - key_url: http://packages.prosody.im/debian/pubkey.asc
   - require_in:
     - pkg: prosody

prosody-packages:
  pkg.installed:
    - pkgs:
      - prosody-0.10
    - require:
      - pkgrepo: prosody-repo

/etc/prosody/prosody.cfg.lua:
  file.managed:
    - source: salt://prosody/prosody.cfg.lua.jinja
    - template: jinja
    - user: root
    - group: prosody
    - mode: 640
    - watch_in:
      - service: prosody
    - require:
      - pkg: prosody-packages

prosody-read-certificates:
  user.present:
    - name: prosody
    - optional_groups:
      - certificates
    - remove_groups: False

prosody:
  pkg.installed: []
  service.running:
    - enable: True
    - reload: True
    - sig: "/usr/bin/lua5.1 /usr/bin/prosody"
    - watch:
      - file: /etc/prosody/prosody.cfg.lua
    - require:
      - pkg: prosody

prosody-firewall-c2s:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - dport: 5222
    - proto: tcp
    - save: True
    - match: comment 
    - comment: xmpp-s2s
    - save: true

prosody-firewall-s2s:
  iptables.append:
    - table: filter
    - chain: INPUT
    - jump: ACCEPT
    - match: state
    - connstate: NEW
    - dport: 5269
    - proto: tcp
    - save: True
    - match: comment 
    - comment: xmpp-s2s
    - save: true
