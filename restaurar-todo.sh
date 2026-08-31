#!/bin/bash
# Reactiva TODAS las apps desactivadas en la TV Cobia R3.
# Uso: ./restaurar-todo.sh
set -u
TV="192.168.0.55:5555"
command -v adb >/dev/null || { echo "Falta adb: brew install --cask android-platform-tools"; exit 1; }
adb connect "$TV" >/dev/null 2>&1
adb -s "$TV" get-state >/dev/null 2>&1 || { echo "No conecta con la TV. Revisa que este encendida y con depuracion ADB activa."; exit 1; }
cd "$(dirname "$0")"
n=0
while read -r p; do
  [ -z "$p" ] && continue
  adb -s "$TV" shell "pm enable $p" </dev/null >/dev/null 2>&1 && n=$((n+1))
done < apps-desactivadas.txt
echo "Reactivadas: $n"
echo "IMPORTANTE: esto tambien reactiva el launcher de Google, que competira con Projectivy."
echo "Si quieres quedarte solo con Projectivy:  adb -s $TV shell pm disable-user --user 0 com.google.android.tvlauncher"
sleep 15; adb -s "$TV" reboot
