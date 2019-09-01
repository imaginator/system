#!/bin/bash
set -xe
adb install -r -g de.vier_bier.habpanelviewer_8.apk
adb connect test-wall-tablet:5555 && sleep 1
adb shell settings put global wifi_sleep_policy 2
adb shell svc power stayon true
adb shell pm disable org.cyanogenmod.audiofx
adb shell pm disable com.cyanogenmod.trebuchet
adb shell pm clear de.vier_bier.habpanelviewer
adb shell pm disable de.vier_bier.habpanelviewer
adb push shared_prefs /data/data/de.vier_bier.habpanelviewer/
adb shell pm enable de.vier_bier.habpanelviewer
adb shell am start -n de.vier_bier.habpanelviewer/.MainActivity
adb shell dpm set-device-owner de.vier_bier.habpanelviewer/.AdminReceiver
adb disconnect