#!/bin/bash
set -x

export room=$1

if [[ $(echo "$room" | grep -LE 'Kitchen|Lounge|Study|HallwayLarge|BathroomMain|BathroomGuest|Bedroom1|Bedroom2|Bedroom3') ]]; then 
  echo "Missing room parameter incorrectly capitalised e.g Lounge"
  exit 1
fi

echo "Deploying to $room"

if [[ ! -f /tmp/org.openhab.habdroid.apk ]] ; then
  curl -o /tmp/de.vier_bier.habpanelviewer.apk  https://github.com/vbier/habpanelviewer/releases/download/0.9.27/app-debug.apk
fi

echo "running ADB non-root commands"
adb kill-server
adb connect tablet-$room.imagilan:5555 && sleep 2


adb shell appops set android TOAST_WINDOW deny                                              # this would deny all toasts from Android System
adb shell setprop persist.adb.tcp.port 5555                                                 # keep adb via wifi enabled
adb shell setprop persist.sys.timezone Europe/Berlin
adb shell settings put global bluetooth_on 0
adb shell settings put global wifi_on 1
adb shell settings put global wifi_sleep_policy 2
adb shell settings put system accelerometer_rotation 1
adb shell settings put system screen_brightness_mode_automatic 1                            # auto brightness mode
adb shell settings put system screen_brightness 255
adb shell settings put system screen_off_timeout 70000                                      # milliseconds (now shut off here rather than rule)
adb shell settings put system user_rotation 1
adb shell settings put system volume_system 0
adb shell svc power stayon true
adb shell svc wifi enable

adb uninstall           de.vier_bier.habpanelviewer
adb   install -r   /tmp/de.vier_bier.habpanelviewer.apk
adb shell dumpsys deviceidle whitelist +de.vier_bier.habpanelviewer                              # disable battery optimisation
adb shell pm grant de.vier_bier.habpanelviewer android.permission.RECORD_AUDIO #stupid dialogs
adb shell pm grant de.vier_bier.habpanelviewer android.permission.CAMERA
adb shell dumpsys deviceidle whitelist +de.vier_bier.habpanelviewer  # disable battery optimisation
adb shell cmd package set-home-activity de.vier_bier.habpanelviewer/.StartActivity # set as launcher

# needed to write to /data
echo "running ADB root commands"   
adb root &&  adb connect tablet-$room.imagilan:5555 && sleep 2

envsubst < de.vier_bier.habpanelviewer_preferences.xml >  /tmp/de.vier_bier.habpanelviewer_preferences.xml
adb shell mkdir -p                                        /data/data/de.vier_bier.habpanelviewer/shared_prefs
adb push /tmp/de.vier_bier.habpanelviewer_preferences.xml /data/data/de.vier_bier.habpanelviewer/shared_prefs/de.vier_bier.habpanelviewer_preferences.xml
adb push _has_set_default_values.xml                      /data/data/de.vier_bier.habpanelviewer/shared_prefs/_has_set_default_values.xml
adb shell chmod -R 777                                    /data/data/de.vier_bier.habpanelviewer/shared_prefs/

# Disable lock screen
adb shell /system/bin/sqlite3 /data/system/locksettings.db \"UPDATE locksettings SET value = \'1\' WHERE name = \'lockscreen.disabled\'\"
adb shell /system/bin/sqlite3 /data/system/locksettings.db \"UPDATE locksettings SET value = \'0\' WHERE name = \'lockscreen.password_type\'\"
adb shell /system/bin/sqlite3 /data/system/locksettings.db \"UPDATE locksettings SET value = \'0\' WHERE name = \'lockscreen.password_type_alternate\'\"

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
adb shell pm disable org.lineageos.eleven
adb shell pm disable org.lineageos.lockclock
adb shell pm disable org.lineageos.setupwizard
adb shell pm disable org.lineageos.audiofx
adb shell pm disable org.lineageos.recorder

adb reboot
adb disconnect tablet-$room.imagilan

#adb shell am start -n org.openhab.habdroid/.ui.MainActivity
