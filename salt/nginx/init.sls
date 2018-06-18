nginx:
  service:
    - running
    - watch:
      - file: /etc/nginx/nginx.conf
      - file: /etc/nginx/sites-enabled/*
    - require:
      - pkg: nginx_pkgs

nginx_pkgs:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs:
      - nginx-full
      - certbot

bunker.imaginator.com:
  acme.cert:
    - renew: 14
    - test_cert: True
    - owner: root
    - group: certificates
    - watch_in:
      - service: nginx
    - require_in:
      - service: nginx

/etc/nginx/nginx.conf:
  file.managed:
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

/etc/nginx/snippets/ssl.conf:
  file.managed:
    - source: salt://nginx/ssl.conf
    - user: root
    - group: root
    - mode: 644

/etc/nginx/snippets/letsencrypt.conf:
  file.managed:
    - source: salt://nginx/letsencrypt.conf
    - user: root
    - group: root
    - mode: 644

/var/www/letsencrypt/.well-known/acme-challenge:
  file.directory:
    - mode: 755
    - makedirs: True

/etc/nginx/sites-enabled/default:
  file.absent

/etc/nginx/sites-enabled/_.conf:
  file.managed:
    - source: salt://nginx/_.conf
    - user: root
    - group: root
    - mode: 644

/etc/nginx/sites-enabled/bunker.imaginator.com.conf:
  file.managed:
    - source: salt://nginx/bunker.imaginator.com.conf
    - user: root
    - group: root
    - mode: 644

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
