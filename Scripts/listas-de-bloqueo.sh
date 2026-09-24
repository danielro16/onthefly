#!/bin/bash
# Regenera las listas de bloqueo (EasyList y EasyPrivacy) en el formato de
# WebKit, con el convertidor de AdGuard (SafariConverterLib, GPL-3.0: se usa
# en la Mac, no va en la app). Lo que sale va en Sources/Engine/Bloqueo, bajo
# CC BY-SA 3.0, con la atribución de Sources/Engine/Bloqueo/LICENCIA.md.
#
#   ./Scripts/listas-de-bloqueo.sh
#
# Necesita Swift (Xcode). La primera vez compila el convertidor desde el
# código de AdGuard, en la versión fija de abajo.
set -euo pipefail
RAIZ="$(cd "$(dirname "$0")/.." && pwd)"
TRABAJO="${TMPDIR:-/tmp}/jef-listas"
VERSION="v4.3.0"
DESTINO="$RAIZ/Sources/Engine/Bloqueo"
mkdir -p "$TRABAJO"

if [ ! -x "$TRABAJO/fuente/.build/release/ConverterTool" ]; then
  rm -rf "$TRABAJO/fuente"
  git clone -q --depth 1 --branch "$VERSION" https://github.com/AdguardTeam/SafariConverterLib.git "$TRABAJO/fuente"
  (cd "$TRABAJO/fuente" && swift build -c release --product ConverterTool)
fi
CONVERTIR="$TRABAJO/fuente/.build/release/ConverterTool"

for lista in easylist easyprivacy; do
  curl -sfL "https://easylist.to/easylist/$lista.txt" -o "$TRABAJO/$lista.txt"
  "$CONVERTIR" convert --safari-version 18.0 --input-path "$TRABAJO/$lista.txt" \
    --safari-rules-json-path "$DESTINO/$lista.json" --advanced-blocking-rules-path "$TRABAJO/$lista-avanzadas.txt"
  echo "$lista: $(grep -m1 '^! Version:' "$TRABAJO/$lista.txt" | cut -d' ' -f3)"
done
echo "Actualizar las versiones en $DESTINO/LICENCIA.md."
