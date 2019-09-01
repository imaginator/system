#!/bin/bash
set -xe
adb connect test-wall-tablet:5555 && sleep 1
adb shell pm disable org.cyanogenmod.audiofx
adb shell pm disable com.cyanogenmod.trebuchet
adb shell pm clear de.vier_bier.habpanelviewer
adb shell pm disable de.vier_bier.habpanelviewer
adb push shared_prefs /data/data/de.vier_bier.habpanelviewer/
adb shell pm enable de.vier_bier.habpanelviewer
adb shell am start -n de.vier_bier.habpanelviewer/.MainActivity
adb disconnect