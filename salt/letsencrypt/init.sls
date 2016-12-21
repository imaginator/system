#install certbot
certbot:
  pkg.latest:
{% if grains['osfinger'] == "Debian-8" %}
    - fromrepo: jessie-backports
{% endif %}
    - pkgs:
      - certbot

# install cli configuration
/etc/letsencrypt/cli.ini:
  file.managed:
    - source: salt://letsencrypt/files/cli.ini.j2
    - user: root
    - group: root
    - mode: 644
    - makedirs: True
    - template: jinja
    - require:
      - pkg: certbot

# remove default cron job
/etc/cron.d/certbot:
  file.absent

# setup a systemd timer instead
/etc/systemd/system/certbot.service:
  file.managed:
    - source: salt://letsencrypt/files/certbot.service
    - user: root
    - group: root
    - mode: 644

/etc/systemd/system/certbot.timer:
  file.managed:
    - source: salt://letsencrypt/files/certbot.timer
    - user: root
    - group: root
    - mode: 644

/etc/systemd/system/certbot.service.d:
  file.directory:
    - user: root
    - group: root
    - dir_mode: 755

certbot.timer:
  service.running:
    - enable: True
    - require:
      - file: /etc/systemd/system/certbot.service
      - file: /etc/letsencrypt/cli.ini


# helper script taken from https://github.com/saltstack-formulas/letsencrypt-formula/blob/master/letsencrypt/domains.sls
/usr/local/bin/check_letsencrypt_cert.sh:
  file.managed:
    - mode: 755
    - contents: |
        #!/bin/bash
        FIRST_CERT=$1

        for DOMAIN in "$@"
        do
            openssl x509 -in /etc/letsencrypt/live/$1/cert.pem -noout -text | grep DNS:${DOMAIN} > /dev/null || exit 1
        done
        CERT=$(date -d "$(openssl x509 -in /etc/letsencrypt/live/$1/cert.pem -enddate -noout | cut -d'=' -f2)" "+%s")
        CURRENT=$(date "+%s")
        REMAINING=$((($CERT - $CURRENT) / 60 / 60 / 24))
        [ "$REMAINING" -gt "30" ] || exit 1
        echo Domains $@ are in cert and cert is valid for $REMAINING days


# request initial certs
{% for setname, domainlist in pillar['letsencrypt']['domainsets'].iteritems() %}

certbot_certonly_initial_{{ setname }}_{{ domainlist|join('+') }}:
  cmd.run:
    - name: /usr/bin/certbot certonly -d {{ domainlist|join(' -d ') }}
    - unless: /usr/local/bin/check_letsencrypt_cert.sh {{ domainlist | join(' ') }}
    - require:
      - file: /usr/local/bin/check_letsencrypt_cert.sh

{% endfor %}

# any process belonging to the certificates group can read the certificate files
create-certificates-group:
  group.present:
    - system: True
    - name: certificates
    - members:
      - www-data

/etc/letsencrypt/live:
  file.directory:
    - makedirs: True
    - user: root
    - group: certificates
    - mode: 640
    - recurse:
      - user
      - group
      - mode
    - require: 
      - group: certificates
