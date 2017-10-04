emby-repo:
  pkgrepo.managed:
    - name: deb http://download.opensuse.org/repositories/home:/emby/xUbuntu_14.04/ /

emby:
  pkg.installed:
    - name: emby-server
    - require_in:
      - pkgrepo: emby-repo
  service.running:
    - name: emby-server
    - enable: true
    - require:
      - pkg: emby-server


/etc/nginx/conf.d/nginx-emby.conf:
  file:
    - managed
    - makedirs: true
    - user: root
    - group: root
    - source: salt://emby/nginx-emby.conf
    - require:
      - pkg: nginx-full
      - pkg: emby-server

emby_iptables:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: tcp
    - jump: accept-log
    - dports: 8096,8945,8920
    - family: ipv4
    - match: comment 
    - comment: emby-web
    - save: true
