#!/bin/bash 
set -x
cat << _EOF_
log:set DEBUG
smarthome:links clear
smarthome:items clear
smarthome:things clear
config:property-set -p org.openhab.addons remote true
config:property-set -p org.openhab.addons experimental true
config:property-set -p org.openhab.habpanel initialPanelConfig F17
config:property-set -p org.openhab.habpanel panelsRegistry '$(cat /srv/salt_local/salt/openhab/files/other-configs/habpanel-config.json | jq -ca . )'
_EOF_
