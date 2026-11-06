#!/usr/bin/env bash
set -e

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DEST="$HOME/.local/bin"
APP_DEST="$HOME/.local/share/applications"
ICON_DEST="$HOME/.local/share/icons/hicolor/scalable/apps"

echo "==> Compilando KPhone en Release..."
cmake -B "$SRC/build" -S "$SRC" -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build "$SRC/build"

echo "==> Ejecutando tests automatizados..."
ctest --test-dir "$SRC/build" --output-on-failure

echo "==> Instalando binario en $BIN_DEST/kphone..."
mkdir -p "$BIN_DEST"
install -m 755 "$SRC/build/src/kphone" "$BIN_DEST/kphone"

echo "==> Instalando icono en $ICON_DEST..."
mkdir -p "$ICON_DEST"
install -m 644 "$SRC/src/resources/icons/kphone.svg" "$ICON_DEST/kphone.svg"

echo "==> Instalando archivo de escritorio en $APP_DEST..."
mkdir -p "$APP_DEST"
install -m 644 "$SRC/data/org.cesar.kphone.desktop" "$APP_DEST/org.cesar.kphone.desktop"

echo "==> Actualizando base de datos de servicios de escritorio..."
update-desktop-database "$APP_DEST" 2>/dev/null || true
gtk-update-icon-cache "$HOME/.local/share/icons/hicolor" 2>/dev/null || true

echo "==> ¡Instalación completada con éxito!"
