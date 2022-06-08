#!/bin/bash
#set -x

export room=$1

if [[ $(echo "$room" | grep -LE 'Kitchen|Lounge|Study|HallwayLarge|BathroomMain|BathroomGuest|Bedroom1|Bedroom2|Bedroom3') ]]; then 
  echo "Missing room parameter incorrectly capitalised e.g Lounge"
  exit 1
fi

echo "Deploying to $room"

if [[ ! -f /tmp/org.openhab.habdroid.apk ]] ; then
  curl -o /tmp/org.openhab.habdroid.apk  https://f-droid.org/repo/org.openhab.habdroid_418.apk
fi

echo "running ADB non-root commands"
adb kill-server
adb connect tablet-$room.imagilan:5555 && sleep 2
adb shell settings put global bluetooth_on 0
adb shell settings put secure lockscreen_disabled 1
adb shell settings put system accelerometer_rotation 1
adb shell settings put system user_rotation 1
adb shell settings put global wifi_sleep_policy 2                                           # stop wifi from sleeping
adb shell svc power stayon false
adb shell setprop persist.sys.timezone Europe/Berlin
adb shell setprop persist.adb.tcp.port 5555                                                 # keep adb via wifi enabled
adb shell settings put system screen_auto_brightness_adj 0.8
adb shell settings put system screen_brightness_mode 1                                      # auto brightness mode
adb shell settings put system screen_off_timeout 120000                                     # milliseconds (now shut off here rather than rule)
adb shell am force-stop org.openhab.habdroid                                                #since disable doesn't kill
adb uninstall org.openhab.habdroid
adb install -r /tmp/org.openhab.habdroid.apk
#adb shell pm grant de.vier_bier.habpanelviewer android.permission.RECORD_AUDIO              #stupid dialogs
#adb shell pm grant de.vier_bier.habpanelviewer android.permission.CAMERA
#adb shell cmd package set-home-activity de.vier_bier.habpanelviewer/.StartActivity          # set as launcher
adb shell dumpsys deviceidle whitelist +org.openhab.habdroid                                 # disable battery optimisation

echo "running ADB root commands"   # needed to write to /data
adb root &&  adb connect tablet-$room.imagilan:5555 && sleep 2

# Disable lock screen
adb shell /system/bin/sqlite3 /data/system/locksettings.db "UPDATE locksettings SET value = '1' WHERE name = 'lockscreen.disabled'"
adb shell /system/bin/sqlite3 /data/system/locksettings.db "UPDATE locksettings SET value = '0' WHERE name = 'lockscreen.password_type'"
adb shell /system/bin/sqlite3 /data/system/locksettings.db "UPDATE locksettings SET value = '0' WHERE name = 'lockscreen.password_type_alternate'"

# add prefs
adb shell mkdir -p                             /data/data/org.openhab.habdroid/shared_prefs
adb shell chmod -R 777                         /data/data/org.openhab.habdroid/shared_prefs
adb push  org.openhab.habdroid_preferences.xml /data/data/org.openhab.habdroid/shared_prefs/org.openhab.habdroid_preferences.xml

# remove cruft 
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

# Notes 

# adb shell dpm set-device-owner com.santoshdevadiga.kiosksample/.DeviceAdminReceiver.
