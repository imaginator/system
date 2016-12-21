libresonic-server:
  pkg.installed:
    - name: libresonic
  service.running:
    - name: libresonic
    - enable: true
    - watch:
      - file: /etc/default/libresonic
    - require:
      - pkg: libresonic

/etc/default/libresonic:
  file:
    - managed
    - makedirs: true
    - user: root
    - group: root
    - source: salt://libresonic/default-libresonic.conf
    - require:
      - pkg: libresonic

/etc/nginx/conf.d/nginx-libresonic.conf:
  file:
    - managed
    - makedirs: true
    - user: root
    - group: root
    - source: salt://libresonic/nginx-libresonic.conf
    - require:
      - pkg: nginx-full
      - pkg: libresonic
