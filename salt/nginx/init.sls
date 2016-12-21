nginx:
  pkg.installed:
    - name: nginx-full
  service:
    - running
    - watch:
      - pkg: nginx-full
      - file: /etc/nginx/nginx.conf
      - file: /etc/nginx/conf.d/*

/etc/nginx/nginx.conf:
  file:
    - managed
    - source: salt://nginx/nginx.conf
    - user: root
    - group: root
    - mode: 644

# Create a unique 2048 Diffie Hellman group
# https://weakdh.org
/etc/nginx/dhparam.pem:
  cmd.run:
    - name: openssl dhparam -out /etc/nginx/dhparam.pem 2048
    - unless: test -f /etc/nginx/dhparam.pem

/etc/nginx/sites-enabled/bunker.imaginator.com.conf:
  file:
    - managed
    - source: salt://nginx/bunker.imaginator.com.conf
    - user: root
    - group: root
    - mode: 644

/etc/nginx/sites-enabled/default:
  file:
    - absent

nginx_iptables_ipv4:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: tcp
    - jump: accept-log
    - dports: 80,443
    - family: ipv4
    - match: comment 
    - comment: web
    - save: true

nginx_iptables_ipv6:
  iptables.append:
    - table: filter
    - chain: INPUT
    - match: state
    - connstate: NEW
    - proto: tcp
    - jump: accept-log
    - dports: 80,443
    - family: ipv6
    - match: comment 
    - comment: web
    - save: true
