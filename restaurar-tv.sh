#!/system/bin/sh
# Corre DENTRO de la TV:  adb shell sh /sdcard/cobia-tv/restaurar-tv.sh
# Lee por el descriptor 3 porque `pm` consume stdin y romperia el bucle.
L=/sdcard/cobia-tv/apps-desactivadas.txt
[ -f "$L" ] || { echo "Falta $L"; exit 1; }
n=0
while read -r p <&3; do
  [ -z "$p" ] && continue
  if pm enable "$p" </dev/null >/dev/null 2>&1; then n=$((n+1)); else echo "  fallo: $p"; fi
done 3< "$L"
echo "Reactivadas: $n"
echo "OJO: esto reactiva tambien el launcher de Google, que competira con Projectivy."
echo "Para dejar solo Projectivy:  pm disable-user --user 0 com.google.android.tvlauncher"
echo "Reinicia con: reboot"
