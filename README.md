# TV Cobia R3 — Declutter y mantenimiento

Documentación del declutter aplicado a la Smart TV **Cobia R3** de la sala el **30 de agosto de 2026**.
Si te encontraste esta carpeta y no sabes qué pasó con la TV, empieza aquí.

---

## TL;DR

Se desactivaron **39 apps** preinstaladas y se reemplazó el launcher de Google por **Projectivy**.
**No se borró nada.** Todo es reversible, y un reset de fábrica restaura el equipo por completo.

Para revertirlo todo: `./restaurar-todo.sh`

---

## El equipo

| | |
|---|---|
| Modelo | COBIA R3 |
| IP | `192.168.0.55` (MAC `94:B3:F7:94:71:CE`) |
| SO | Android TV 11 (API 30), build `RTT7.231207.002` |
| SoC | Realtek `rtd2841a`, 4 núcleos |
| RAM | 1.5 GB |
| Almacenamiento | 4 GB en `/data` |
| Arquitectura | **`armeabi-v7a` solamente — 32 bits, sin `arm64-v8a`** |
| Parche de seguridad | enero 2024 (el fabricante ya no publica actualizaciones) |

---

## Cómo conectarse

```bash
brew install --cask android-platform-tools   # si no tienes adb
adb connect 192.168.0.55:5555
adb devices -l                                # debe decir "device", no "unauthorized"
```

Si dice `unauthorized`, la TV está mostrando un diálogo en pantalla pidiendo autorizar la llave RSA.
Acéptalo con el control y marca *"Permitir siempre desde este equipo"*.

### Si la depuración ADB está apagada

En la TV: **Ajustes → Sistema → Acerca de →** pulsar **OK 7 veces** sobre *Compilación del SO de Google TV*.
Luego **Ajustes → Sistema → Opciones de desarrollador → Depuración USB** (y *Depuración ADB por red* si aparece).

### Si `adb`/`ping` fallan con "No route to host" en macOS

No es la TV ni el router. Es **Local Network Privacy** de macOS 26 bloqueando a tu terminal.
Ve a **Ajustes del Sistema → Privacidad y Seguridad → Red local** y activa el permiso para tu terminal.
Síntoma delator: `arp -a` sí resuelve la MAC de la TV, pero nada responde por unicast.

---

## Qué se cambió

### 1. Declutter — 39 apps desactivadas

Método: `pm disable-user --user 0 <paquete>`. La lista exacta está en **`apps-desactivadas.txt`**.

Se agrupan así:

- **Sintonizador de TV abierta** (`com.apps.atsc`, `atv`, `isdb`, `dtv`, `livetv`, `channels`, `passthrough`) — el dueño solo usa streaming y HDMI. **Si algún día quiere conectar antena o cable coaxial, hay que reactivar estos.**
- **Demo de tienda y herramientas de fábrica** (`com.apps.esticker`, `factory.ui`, `com.realtek.factorytools`, `com.apps.logapp`)
- **Duplicados y funciones sin usar** (`com.creative.fastscreen.tv` que duplica Cast, `com.apps.wifihotspot`, `screensaver`, `function.gdpr`, `com.mk.tv.meeting.service`)
- **`android.autoinstalls.config.scbc.device`** — el stub que reinstala bloatware tras un reset. Vale la pena dejarlo desactivado.
- **Apps no usadas** (Prime Video, YouTube Music, Play Games, Google TV/Videos, Katniss/Asistente de voz)
- **Cruft de Google sin sentido en una TV** (calendario, sincronización, spooler de impresión, galería, shims de CTS, asistentes de configuración inicial ya completados)
- **Actualizador OTA** (`com.apps.ota`, `com.apps.authota`) — ver la advertencia abajo
- **`com.google.android.tvlauncher`** — el launcher de Google, sustituido por Projectivy

### 2. Launcher: Projectivy en lugar del de Google

`com.spocky.projengmenu`, instalado desde Play Store. Elegido tras medir los tres:

| Launcher | PSS promedio |
|---|---|
| `com.google.android.tvlauncher` | 114 MB |
| `me.efesser.flauncher` | 69 MB |
| **`com.spocky.projengmenu` (Projectivy)** | **64 MB** |

FLauncher se probó y se descartó: su último commit es de **marzo de 2023** (~3.5 años abandonado),
no tiene atajos para cambiar de entrada HDMI y solo está en inglés.

Notas sobre Projectivy:
- **No hace falta activar su servicio de accesibilidad.** Solo se necesita cuando no puedes desactivar el launcher de fábrica; aquí sí se desactivó. Además, tenerlo activo impide que apps como Prime Video oculten los controles de reproducción.
- Su **Premium ($7.49, pago único)** solo desbloquea fondos de pantalla e iconos personalizados. **No mejora el rendimiento.** En un equipo de 1.5 GB, poner un fondo animado sería contraproducente.
- Reordenar apps del inicio: **mantener pulsado OK** sobre una app → menú contextual con opciones de mover.

---

## Cómo restaurar

### Opción A — desde la TV, sin computadora (la más fácil)

**Ajustes → Apps → Ver todas las apps →** elegir la app → **Activar**.

Esta es la razón por la que se usó `disable-user` en vez de `uninstall`: las apps desactivadas
siguen apareciendo en esa pantalla. Las desinstaladas-por-usuario no.

### Opción B — restaurar todo de golpe

```bash
./restaurar-todo.sh
```

Reactiva las 39 apps y reinicia. **Ojo:** también reactiva el launcher de Google, que entonces
competirá con Projectivy. Si quieres quedarte solo con Projectivy, tras correrlo ejecuta:

```bash
adb -s 192.168.0.55:5555 shell pm disable-user --user 0 com.google.android.tvlauncher
```

Todos estos archivos están **también dentro de la TV**, en `/sdcard/cobia-tv/`, con versiones
de los scripts que corren en el propio equipo:

```bash
adb -s 192.168.0.55:5555 shell sh /sdcard/cobia-tv/restaurar-tv.sh
```

(Ejecutarlos sigue requiriendo ADB — Android TV no puede correr un `.sh` desde su interfaz.
Para revertir sin computadora, usa la Opción A.)

**Un reset de fábrica borra `/sdcard/cobia-tv/`**, que es justo cuando harían falta. La copia
autoritativa es este repo, no la de la TV.

### Opción C — emergencia: la TV se quedó sin interfaz

Pasa si se desactiva Projectivy sin tener otro launcher activo.

```bash
./rescate-launcher.sh
```

### Opción D — reset de fábrica

Restaura absolutamente todo, incluido el bloatware. Nada de lo que se hizo aquí lo sobrevive.
Para volver a dejarla limpia después: instala Projectivy, verifica que funcione, y corre
`./aplicar-declutter.sh`.

---

## Cómo mantener

```bash
# Ver qué está desactivado ahora mismo
adb -s 192.168.0.55:5555 shell pm list packages -d

# Reactivar una app concreta
adb -s 192.168.0.55:5555 shell pm enable <paquete>

# Desactivar una app nueva
adb -s 192.168.0.55:5555 shell pm disable-user --user 0 <paquete>

# Regenerar la lista de este repo desde el estado real del equipo
adb -s 192.168.0.55:5555 shell pm list packages -d | tr -d '\r' | sed 's/package://' | sort > apps-desactivadas.txt
```

### Cómo medir de verdad si algo ayudó

```bash
# PSS de un proceso concreto — esta es la cifra fiable
adb -s 192.168.0.55:5555 shell "dumpsys meminfo <paquete> | grep -m1 TOTAL"
```

Reglas aprendidas a base de equivocarse:

- **Reinicia antes de medir** y toma **varias muestras espaciadas ~30 s**. Una lectura suelta no vale.
- **Nunca midas justo al arrancar.** FLauncher marcaba 191 MB recién booteado y 69 MB ya estabilizado.
- **`MemAvailable` es demasiado ruidoso** para atribuirle ganancias de pocas decenas de MB: el page cache absorbe lo que se libera. Compara PSS por proceso.
- **Usa el mismo comando en ambos lados de la comparación.** Mezclar `dumpsys meminfo | grep <pkg>` con `dumpsys meminfo <pkg> | grep TOTAL` da números que no son comparables.

---

## Trampas conocidas

**Apps `PERSISTENT` que siguen arrancando.** Algunas apps de sistema traen la bandera `PERSISTENT`
en su manifiesto y el framework las arranca al bootear aunque estén desactivadas. Sin root no se puede
evitar. La desactivación igual sirve — sus servicios y receivers quedan inertes y el proceso queda
como cascarón. Ejemplo real: `com.apps.ota` bajó de 45 MB a 4 MB, pero sigue apareciendo en `ps`.
Comprueba con:

```bash
adb -s 192.168.0.55:5555 shell "dumpsys package <paquete> | grep flags="
```

**PackageManager no persiste al instante.** Si reinicias inmediatamente después de un
`pm enable`/`pm disable-user`, el cambio se pierde y el estado vuelve atrás. Espera ~15 s y
**verifica con `pm list packages -d` antes de reiniciar.** Esto ya causó un cambio de launcher fallido.

**No desactives el único launcher activo.** Instala el nuevo, compruébalo, y solo entonces desactiva
el anterior. Al revés te quedas sin interfaz (recuperable con `rescate-launcher.sh`, pero es un susto).

**Sin actualizaciones de firmware.** `com.apps.ota` y `com.apps.authota` están desactivados. Era
un intercambio consciente: el equipo lleva desde enero de 2024 sin parches y reporta `has_update: false`,
así que gastaba ~51 MB permanentes consultando un servidor que ya no responde. **Si algún día quieres
buscar actualizaciones, reactívalos primero.**

**Seguridad.** La depuración ADB está **activa** porque la TV se usa para desarrollo. En muchos equipos
baratos eso permite control total sin autenticación a cualquiera en la red. No expongas el puerto 5555
en el router. Si dejas de desarrollar, apágala en Opciones de desarrollador.

---

## Resultados medidos

| Métrica | Antes | Después |
|---|---|---|
| RAM disponible | 373 MB | ~500 MB |
| RAM libre | 21 MB | ~130 MB |
| Paquetes activos | 125 | 86 |
| Launcher (PSS) | 114 MB, con anuncios | 64 MB, sin anuncios |

El grueso de la ganancia vino del **declutter de apps**, no del cambio de launcher.
El cambio de launcher aportó ~50 MB adicionales y quitó los anuncios del inicio.

---

## Si vas a desarrollar en esta TV

**El obstáculo principal: `armeabi-v7a` de 32 bits, sin `arm64-v8a`.**

Muchas librerías nativas modernas ya no publican binarios de 32 bits. **Fallan en runtime con
`UnsatisfiedLinkError`, no al compilar** — así que descúbrelo temprano desplegando un build de
prueba antes de escribir código de verdad.

```gradle
ndk { abiFilters "armeabi-v7a" }
```

Otros datos:

- `dalvik.vm.heapgrowthlimit = 192 MB` por app. Los dev builds son glotones: usa Hermes, evita Flipper.
- **`adb reverse tcp:8081 tcp:8081` funciona sobre ADB por red** (verificado), así que Metro y Fast Refresh de React Native funcionan sin configurar IPs a mano.
- Ojo con la terminología: **tvOS es de Apple** y no corre aquí. Esto es **Android TV**. El fork `react-native-tvos` cubre ambas plataformas, pero React Native de línea principal basta si solo apuntas a Android TV — solo añade al manifest:

```xml
<uses-feature android:name="android.software.leanback" android:required="true" />
<uses-feature android:name="android.hardware.touchscreen" android:required="false" />
<!-- y en la activity: -->
<category android:name="android.intent.category.LEANBACK_LAUNCHER" />
```

---

## Archivos de esta carpeta

| Archivo | Para qué |
|---|---|
| `README.md` | Este documento |
| `apps-desactivadas.txt` | Las 39 apps desactivadas, una por línea. Es la fuente de verdad de los scripts. |
| `restaurar-todo.sh` | Reactiva las 39 apps y reinicia |
| `rescate-launcher.sh` | Emergencia: devuelve el launcher de Google si la TV se queda sin interfaz |
| `aplicar-declutter.sh` | Vuelve a aplicar el declutter (p. ej. tras un reset de fábrica) |
| `restaurar-tv.sh` | Igual que `restaurar-todo.sh`, pero corre **dentro** de la TV |
| `aplicar-declutter-tv.sh` | Igual que `aplicar-declutter.sh`, pero corre **dentro** de la TV |

Los scripts terminados en `-tv.sh` se ejecutan en el propio equipo
(`adb shell sh /sdcard/cobia-tv/<script>`); los demás llaman a `adb` desde una computadora.
Ambos grupos leen `apps-desactivadas.txt`, así que regenerar ese archivo actualiza todo.

> **Nota de implementación:** los scripts leen la lista por el descriptor 3 (`while read -r p <&3 ... done 3< "$L"`)
> porque `pm` y `adb shell` consumen stdin y romperían el bucle tras la primera iteración.
