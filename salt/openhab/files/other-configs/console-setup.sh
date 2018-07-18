#!/bin/bash
panelsRegistry=$(jq  --compact-output . /etc/openhab2/other-configs/habpanel-config.json)

cat << _EOF_ | openhab-cli console -b -u openhab -p habopen
config:property-set -p org.openhab.habpanel initialPanelConfig F17
#config:property-set -p org.openhab.habpanel panelsRegistry ${panelsRegistry}
log:set TRACE org.openhab.binding.knx
log:set TRACE calimero
_EOF_


#echo -e $panelsRegistry
#printf -v quotedpanelsRegistry '%q\n' $panelsRegistry
#echo $quotedpanelsRegistry
#config:property-set -p org.openhab.habpanel panelsRegistry $"(echo -e $panelsRegistry)"
