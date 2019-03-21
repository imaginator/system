#!/bin/bash

panelsRegistry=$(jq 'tostring' /etc/openhab2/habpanel/panelsRegistry.json )
jq '.panelsRegistry += '"${panelsRegistry}"'  ' < /etc/openhab2/habpanel/org.openhab.habpanel.json | curl -X PUT --header "Content-Type: application/json" --header "Accept: application/json"  -d @- "http://127.0.0.1:8080/rest/services/org.openhab.habpanel/config"

openhab-cli console -b -u openhab -p habopen <<_EOF_
smarthome:send Tablet_Commands 'RESTART'
_EOF_
