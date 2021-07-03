#!/bin/bash
set -x

export room=$1

if [ -n "$room" ]; then
  echo "Deploying to $room"
else
  echo "Missing room: Kitchen/Lounge/Study/HallwayLarge/BathMain/BathGuest/Bedroom1/2/3"
  exit 0
fi

adb kill-server
adb connect tablet-$room.imagilan
sleep 2

# adb shell dpm remove-active-admin de.vier_bier.habpanelviewer/.AdminReceiver  
adb uninstall de.vier_bier.habpanelviewer
adb install de.vier_bier.habpanelviewer.apk

# adb shell pm disable    de.vier_bier.habpanelviewer

adb root &&  adb connect tablet-$room.imagilan
sleep 2
# needed to write to /data

adb shell rm -r /data/data/de.vier_bier.habpanelviewer/shared_prefs
adb push shared_prefs /data/data/de.vier_bier.habpanelviewer/
# adb shell mv /data/data/de.vier_bier.habpanelviewer/shared_prefs/de.vier_bier.habpanelviewer_preferences.xml /data/data/de.vier_bier.habpanelviewer/shared_prefs/de.vier_bier.habpanelviewer_preferences.xml.old
# envsubst < de.vier_bier.habpanelviewer_preferences.xml | adb exec-in "cat - > /data/data/de.vier_bier.habpanelviewer/shared_prefs/de.vier_bier.habpanelviewer_preferences.xml"
envsubst < de.vier_bier.habpanelviewer_preferences.xml > /tmp/de.vier_bier.habpanelviewer_preferences.xml 
adb push /tmp/de.vier_bier.habpanelviewer_preferences.xml /data/data/de.vier_bier.habpanelviewer/shared_prefs/
adb shell cmd package set-home-activity de.vier_bier.habpanelviewer/.StartActivity # set as launcher
adb shell am force-stop de.vier_bier.habpanelviewer #since disable doesn't kill
adb shell am start -n de.vier_bier.habpanelviewer/.MainActivity

# remove cruft (also only as root)
adb shell pm disable com.android.calculator2
adb shell pm disable com.android.calendar
adb shell pm disable com.android.contacts
adb shell pm disable com.android.deskclock
adb shell pm disable com.android.email
adb shell pm disable com.android.documentsui # file manager
adb shell pm disable com.android.exchange
adb shell pm disable com.android.gallery3d
adb shell pm disable com.android.managedprovisioning
adb shell pm disable com.android.onetimeinitializer
adb shell pm disable com.android.providers.calendar
adb shell pm disable com.android.smspush
adb shell pm disable com.cyanogenmod.eleven
adb shell pm disable com.cyanogenmod.lockclock
adb shell pm disable com.cyanogenmod.setupwizard
adb shell pm disable org.cyanogenmod.audiofx
adb shell pm disable org.cyanogenmod.snap
adb shell pm disable org.lineageos.recorder


adb unroot && adb connect tablet-$room.imagilan
sleep 2

adb de.vier_bier.habpanelviewer/.StartActivity

adb shell settings put global bluetooth_on 0
adb shell settings put system accelerometer_rotation 1
adb shell settings put system user_rotation 1
adb shell settings put global wifi_sleep_policy 2 # stop wifi from sleeping
adb shell svc power stayon false
adb shell setprop persist.sys.timezone Europe/Berlin
adb shell setprop persist.adb.tcp.port 5555   # keep adb via wifi enabled

# disable battery optimistaion
adb shell dumpsys deviceidle whitelist +de.vier_bier.habpanelviewer 
# set device admin permission
# adb shell dpm set-active-admin current de.vier_bier.habpanelviewer/.AdminReceiver  





#adb reboot
adb disconnect
