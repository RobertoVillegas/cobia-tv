#!/system/bin/sh
# Corre DENTRO de la TV:  adb shell sh /sdcard/cobia-tv/aplicar-declutter-tv.sh
# Re-aplica el declutter. Omite el launcher de Google a proposito.
# Lee por el descriptor 3 porque `pm` consume stdin y romperia el bucle.
L=/sdcard/cobia-tv/apps-desactivadas.txt
[ -f "$L" ] || { echo "Falta $L"; exit 1; }
n=0
while read -r p <&3; do
  [ -z "$p" ] && continue
  [ "$p" = "com.google.android.tvlauncher" ] && continue
  if pm disable-user --user 0 "$p" </dev/null >/dev/null 2>&1; then n=$((n+1)); else echo "  fallo: $p"; fi
done 3< "$L"
echo "Desactivadas: $n  (launcher de Google omitido a proposito)"
echo "Instala Projectivy y compruebalo ANTES de desactivar com.google.android.tvlauncher"
