#!jinja|yaml
/etc/openvpn/client.conf:
  file.managed:
    - source: salt://openvpn-client/client.conf
    - template: jinja
    - context:
      id: "{{ grains['id'] }}"
      server: "{{ pillar['openvpn-client']['server']}}"

/etc/certificates/openvpn-client-vpn03.berlin.freifunk.net.key.pem:
  file.managed:
    - makedirs: True
    - user: root
    - group: certificates
    - mode: 600
    - contents_pillar: openvpn-certificates:vpn03.berlin.freifunk.net:key

/etc/certificates/openvpn-client-vpn03.berlin.freifunk.net.cert.pem:
  file.managed:
    - makedirs: True
    - user: root
    - group: certificates
    - mode: 600
    - contents_pillar: openvpn-certificates:vpn03.berlin.freifunk.net:cert

/etc/certificates/openvpn-client-vpn03.berlin.freifunk.net.ca.pem:
  file.managed:
    - makedirs: True
    - user: root
    - group: certificates
    - mode: 600
    - contents_pillar: openvpn-certificates:vpn03.berlin.freifunk.net:ca

openvpn:
  pkg.installed: []
  service.running:
    - enable: True
    - require:
      - pkg: openvpn
    - watch:
      - file: /etc/openvpn/client.conf
      - file: /etc/certificates/openvpn-client-vpn03.berlin.freifunk.net.key.pem
      - file: /etc/certificates/openvpn-client-vpn03.berlin.freifunk.net.cert.pem
      - file: /etc/certificates/openvpn-client-vpn03.berlin.freifunk.net.ca.pem

