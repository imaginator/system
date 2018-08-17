#!/bin/bash

openhab-cli console -b -u openhab -p habopen << _EOF_
#log:set INFO
#log:set INFO org.openhab.binding.knx
#log:set INFO calimero
#smarthome:inbox clear
#smarthome:items clear
#smarthome:things clear
#smarthome:links clear 
#log:set ERR org.openhab.binding.ipcamera
_EOF_
