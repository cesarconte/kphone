# KPhone 📞

> **macOS-style Phone App & Dialer for KDE Plasma 6 (Wayland Native)**

KPhone is a native KDE Plasma 6 telecommunication client designed following the Apple macOS Human Interface Guidelines and KDE Kirigami standards. It bridges KDE Connect telephony and Phone Mirroring into a seamless, high-performance desktop phone experience on CachyOS / Arch Linux.

---

## 🌟 Características

- **🔢 Marcador Numérico macOS (Keypad):**
  - Teclado telefónico circular idéntico al de iOS/macOS con tipografía semántica y letras DTMF.
  - Generación de tonos DTMF en tiempo real mediante síntesis senoidal pura de baja latencia con envolvente suave (eliminando clics de audio).
  - Enrutamiento directo al servidor de audio **PipeWire / WirePlumber**, respetando completamente la cadena de efectos DSP de **EasyEffects**.
  - Formateo inteligente de números telefónicos nacionales (España 9 dígitos) e internacionales (E.164).

- **👥 Integración con Contactos de tu Teléfono:**
  - Sincronización instantánea con los contactos del smartphone almacenados por KDE Connect (`~/.local/share/kpeoplevcard/`).
  - Búsqueda difusa en tiempo real por nombre, teléfono o correo.
  - Ficha de contacto con accesos rápidos: **Llamar**, **Mensaje (SMS)**, **Duplicación de pantalla** y **Favorito**.

- **🕒 Historial de Llamadas (Recientes):**
  - Registro de llamadas salientes, entrantes y perdidas con marcas de tiempo relativas ("Ayer", "14:20") y duración.
  - Filtro instantáneo de llamadas perdidas.

- **📱 Integración profunda con KDE Connect y Phone Mirroring:**
  - Monitorización D-Bus del estado del teléfono emparejado (nombre del terminal y porcentaje de batería).
  - Detección de llamadas entrantes en tiempo real mediante señales D-Bus de `org.kde.kdeconnect.device.telephony`.
  - Acceso directo a `kphonemirroring` / `scrcpy` con un solo clic.

---

## 🛠️ Stack Tecnológico

- **Framework:** Qt 6.12 + KDE Frameworks 6.31 (Kirigami, KCoreAddons, KI18n)
- **Audio:** PipeWire + WirePlumber con DSP EasyEffects
- **Servidor gráfico:** Wayland estricto (cero dependencias de X11)
- **Compilador:** C++20 / GCC 16 con Ninja y CMake 3.22+
- **Control de versiones:** Git / GitHub

---

## 🚀 Compilación e Instalación

```bash
git clone https://github.com/cesarconte/kphone.git
cd kphone
./install.sh
```

Para ejecutar los tests automáticos:

```bash
ctest --test-dir build --output-on-failure
```

---

## 📄 Licencia

GPL-3.0-or-later. Desarrollado para el ecosistema KDE Plasma 6.
