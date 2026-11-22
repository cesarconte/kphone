#!/usr/bin/env bash
set -e

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Compilando KPhone en Release..."
cmake -B "$SRC/build" -S "$SRC" -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build "$SRC/build"

echo "==> Ejecutando tests automatizados..."
ctest --test-dir "$SRC/build" --output-on-failure

echo "==> Instalando en /usr..."
sudo -n cmake --install "$SRC/build" --prefix /usr

echo "==> ¡Instalación completada con éxito!"
