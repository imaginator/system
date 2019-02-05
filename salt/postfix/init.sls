postfix:
  service.running: 
    - enable: True
    - reload: True
    - watch:
      - file: /etc/postfix/main.cf
      - file: /etc/postfix/master.cf
      - file: /etc/mailname
    - require:
      - pkg: postfix_pkgs
      - file: /etc/postfix/main.cf
      - file: /etc/postfix/master.cf
      - file: /etc/mailname
      - cmd: /etc/postfix/sasl_password.db

postfix_pkgs:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs:
      - postfix
      - bsd-mailx
      - getmail
      - mailutils 
      - libsasl2-2 
      - ca-certificates 
      - libsasl2-modules

/etc/postfix/main.cf:
  file.managed:
    - source: salt://postfix/files/main.cf
    - user: root
    - group: root
    - mode: 644

/etc/postfix/master.cf:
  file.managed:
    - source: salt://postfix/files/master.cf
    - user: root
    - group: root
    - mode: 644

/etc/mailname:
  file.managed:
    - source: salt://postfix/files/mailname
    - user: root
    - group: root
    - mode: 644

/etc/postfix/sasl_password.db:
  cmd.run:
    - name: postmap /etc/postfix/sasl_password
