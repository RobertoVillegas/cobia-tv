#!/bin/bash
# EMERGENCIA: la TV se quedo sin interfaz. Reactiva el launcher de Google.
TV="192.168.0.55:5555"
adb connect "$TV" >/dev/null 2>&1
adb -s "$TV" shell "pm enable com.google.android.tvlauncher" </dev/null
sleep 15
adb -s "$TV" reboot
echo "Launcher de Google reactivado. La TV se esta reiniciando."
