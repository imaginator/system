# do this:

```
go get github.com/prometheus/snmp_exporter/generator
cd ${GOPATH-$HOME/go}/src/github.com/prometheus/snmp_exporter/generator
go build
export MIBDIRS=/usr/share/snmp/mibs:$HOME/.snmp/mibs/ubiquiti:$HOME/.snmp/mibs/broadcom:./mibs
cp /srv/salt_local/salt/prometheus-snmp-exporter/files/generator.yml .
./generator --log.level="debug" generate
cp  snmp.yml /srv/salt_local/salt/prometheus-snmp-exporter/files/snmp.yml
sudo salt  "bunker" state.apply prometheus-snmp-exporter   --log-level=info --state-output=changes
```