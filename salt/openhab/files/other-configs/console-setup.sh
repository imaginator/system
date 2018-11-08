#!/bin/bash

openhab-cli console -b -u openhab -p habopen << _EOF_
# smarthome:inbox clear
# smarthome:items clear
# smarthome:things clear
# smarthome:links clear 
_EOF_
