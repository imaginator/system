#!/bin/bash

openhab-cli console -b -u openhab -p habopen << _EOF_
smarthome:items clear
smarthome:things clear
smarthome:links clear
smarthome:inbox clear
_EOF_
