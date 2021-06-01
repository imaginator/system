#!/bin/bash
set -xe

adb root

# https://f-droid.org/packages/de.vier_bier.habpanelviewer/
adb install -r de.vier_bier.habpanelviewer_8.apk
adb shell pm clear de.vier_bier.habpanelviewer

# force landscape
adb shell settings put system accelerometer_rotation 0  #disable auto-rotate
adb shell settings put system user_rotation 1

# stop wifi from sleeping
adb shell settings put global wifi_sleep_policy 2

# never sleep while attached to power
adb shell svc power stayon true

# stop habpanelviewer before switching in new preferences
adb shell pm disable de.vier_bier.habpanelviewer

# copy preferences from server
adb push shared_prefs /data/data/de.vier_bier.habpanelviewer/

# re-enable habpanelviewer
adb shell pm enable de.vier_bier.habpanelviewer

# start habpanelviewer with new preferences
adb shell am start -n de.vier_bier.habpanelviewer/.MainActivity

# set timezone
adb shell setprop persist.sys.timezone Europe/Berlin


# remove cruft
adb shell pm disable org.cyanogenmod.audiofx
adb shell pm disable com.cyanogenmod.trebuchet

adb reboot
