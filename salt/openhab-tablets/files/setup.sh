#!/bin/bash
#set -x

export room=$1

if [[ $(echo "$room" | grep -LE 'Kitchen|Lounge|Study|HallwayLarge|BathroomMain|BathroomGuest|Bedroom1|Bedroom2|Bedroom3') ]]; then 
  echo "Missing room parameter incorrectly capitalised e.g Lounge"
  exit 1
fi

echo "Deploying to $room"

echo "running ADB non-root commands"
adb kill-server
adb connect tablet-$room.imagilan:5555 && sleep 2
adb shell settings put global bluetooth_on 0
adb shell settings put system accelerometer_rotation 1
adb shell settings put system user_rotation 1
adb shell settings put global wifi_sleep_policy 2 # stop wifi from sleeping
adb shell svc power stayon false
adb shell setprop persist.sys.timezone Europe/Berlin
adb shell setprop persist.adb.tcp.port 5555   # keep adb via wifi enabled
adb shell settings put system screen_auto_brightness_adj 0.8
adb shell settings put system screen_brightness_mode 1 # auto brightness mode
adb shell settings put system screen_off_timeout 120000    # milliseconds (needs to be longer than rule)
adb shell am force-stop de.vier_bier.habpanelviewer #since disable doesn't kill
adb uninstall de.vier_bier.habpanelviewer
adb install de.vier_bier.habpanelviewer.apk
adb shell pm grant de.vier_bier.habpanelviewer android.permission.RECORD_AUDIO #stupid dialogs
adb shell pm grant de.vier_bier.habpanelviewer android.permission.CAMERA
adb shell cmd package set-home-activity de.vier_bier.habpanelviewer/.StartActivity # set as launcher
adb shell dumpsys deviceidle whitelist +de.vier_bier.habpanelviewer  # disable battery optimisation

# config files
adb shell run-as de.vier_bier.habpanelviewer mkdir -p    /data/data/de.vier_bier.habpanelviewer/shared_prefs
envsubst < de.vier_bier.habpanelviewer_preferences.xml > /tmp/de.vier_bier.habpanelviewer_preferences.xml
adb push /tmp/de.vier_bier.habpanelviewer_preferences.xml /sdcard/de.vier_bier.habpanelviewer_preferences.xml
adb push _has_set_default_values.xml                      /sdcard/_has_set_default_values.xml
adb shell run-as de.vier_bier.habpanelviewer  cp /sdcard/_has_set_default_values.xml  /data/data/de.vier_bier.habpanelviewer/shared_prefs/_has_set_default_values.xml
adb shell run-as de.vier_bier.habpanelviewer  cp /sdcard/de.vier_bier.habpanelviewer_preferences.xml /data/data/de.vier_bier.habpanelviewer/shared_prefs/de.vier_bier.habpanelviewer_preferences.xml


echo "running ADB root commands"   # needed to write to /data
adb root &&  adb connect tablet-$room.imagilan:5555 && sleep 2
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
adb reboot
adb disconnect tablet-$room.imagilan