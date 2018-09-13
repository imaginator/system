#!/bin/bash
# u0027 is a: " ' " character
# u0024 is a: " $ " character

panelsRegistry=$(jq --compact-output . /etc/openhab2/other-configs/habpanel-config.json | sed "s/'/\\\\u0027/g" )

openhab-cli console -b -u openhab -p habopen << _EOF_
config:property-set -p org.openhab.habpanel lockEditing false
config:property-set -p org.openhab.habpanel initialPanelConfig F17
config:property-set -p org.openhab.habpanel panelsRegistry '${panelsRegistry}'
_EOF_
