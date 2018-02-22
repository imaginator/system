mopidy-repo:        
  pkgrepo.managed:        
    - human_name: Mopidy Repository        
    - name: deb http://apt.mopidy.com stable main        
    - file: /etc/apt/sources.list.d/mopidy.list        
    - keyid: 271D2943        
    - keyserver: keyserver.ubuntu.com        
    - require_in:        
      - pkg: mopidy        

mopidy-dependencies:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs:
      - icecast2
      - apache2-utils
      - nginx-full
      - gstreamer1.0-plugins-good
      - gstreamer1.0-plugins-base
      - gstreamer1.0-tools

install-mopidy:
  pkg.installed:
    - cache_valid_time: 30000
    - pkgs: 
      - mopidy
      - mopidy-local-sqlite

/etc/nginx/sites-enabled/music.imaginator.com.conf:
  file:
    - managed
    - user: root
    - group: root
    - source: salt://mopidy/files/nginx-mopidy.conf

mopidy-webaccess:
  webutil.user_exists:
    - name: simon
    - password: {{ salt['pillar.get']('mopidy:htaccess_password') }}
    - htpasswd_file: /etc/nginx/htpasswd
    - options: s

/etc/mopidy/mopidy.conf:
  file.managed:
    - source: salt://mopidy/files/mopidy.conf.jinja
    - user: mopidy
    - group: root
    - mode: 0644
    - template: jinja

mopidy:
  service.running:
    - enable: True
    - require:
      - pkg: mopidy-dependencies
    - watch:
      - file: /etc/mopidy/mopidy.conf


# vim:ft=yaml:
