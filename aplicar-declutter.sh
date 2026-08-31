#!/bin/bash
# Re-aplica el declutter (util despues de un reset de fabrica).
set -u
TV="192.168.0.55:5555"
adb connect "$TV" >/dev/null 2>&1
adb -s "$TV" get-state >/dev/null 2>&1 || { echo "No conecta con la TV."; exit 1; }
cd "$(dirname "$0")"
n=0
while read -r p; do
  [ -z "$p" ] && continue
  [ "$p" = "com.google.android.tvlauncher" ] && continue   # solo tras instalar Projectivy
  adb -s "$TV" shell "pm disable-user --user 0 $p" </dev/null >/dev/null 2>&1 && n=$((n+1))
done < apps-desactivadas.txt
echo "Desactivadas: $n  (el launcher de Google se omitio a proposito)"
echo "Instala Projectivy y verifica que funcione ANTES de desactivar com.google.android.tvlauncher"
