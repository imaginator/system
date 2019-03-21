#!/bin/bash

openhab-cli console -b -u openhab -p habopen << _EOF_
smarthome:things clear
smarthome:inbox clear
_EOF_
