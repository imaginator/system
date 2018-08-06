#!/bin/bash

openhab-cli console -b -u openhab -p habopen << _EOF_
log:set ERROR
log:set TRACE org.openhab.binding.knx
log:set TRACE calimero
log:set DEBUG org.openhab.binding.ipcamera
_EOF_
