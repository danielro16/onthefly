#!/bin/zsh
# Walks the aerolineas.com.ar purchase funnel in the simulator the way a
# VoiceOver user would: every step is a tap on an accessibility label, and
# every check reads the accessibility tree. No screenshots decide anything.
#
#   ./Scripts/flow-aerolineas.sh funnel     # calendar → fares → checkout
#   ./Scripts/flow-aerolineas.sh passenger  # fill the passenger form, press "Siguiente"
#
# UDID=... overrides the simulator. Each stage stays under ten minutes.

set -u
U=${UDID:-233986A3-851C-4FA3-83AF-0A64E047E60C}
cd "$(dirname "$0")/.."
W() { ./Scripts/voiceover-walk.py --udid "$U" 2>&1; }
T() { ./Scripts/voiceover-tap.py "$@" --udid "$U"; }
paste_into() {  # $1 label, $2 text — the Spanish keyboard mangles `axe type` symbols
  T "$1" --type TextField; sleep 1.5
  printf '%s' "$2" | xcrun simctl pbcopy "$U"
  axe key-combo --modifiers 227 --key 25 --udid "$U" >/dev/null; sleep 2
}
type_into() { T "$1" --type TextField; sleep 1.5; axe type "$2" --udid "$U" >/dev/null; sleep 2; }
pick() {  # $1 field, $2 option text — opens the whole list, chooses by text
  T "Opciones de $1" --type Button; sleep 4
  local c; c=$(W | grep -m1 "\. $2  (Elige esta opción para $1)" | sed -E 's/^ *[0-9]+ \[btn\] (.*)  \(Elige.*$/\1/')
  if [ -z "$c" ]; then echo "sin opción '$2' para $1"; return 1; fi
  T "$c" --type Button; sleep 3
}
filter_pick() {  # $1 field, $2 typed, $3 option text — types to filter, then chooses
  type_into "$1" "$2"; sleep 4
  local c; c=$(W | grep -m1 "\. $3  (Elige esta opción para $1)" | sed -E 's/^ *[0-9]+ \[btn\] (.*)  \(Elige.*$/\1/')
  if [ -z "$c" ]; then echo "sin opción '$3' para $1"; return 1; fi
  T "$c" --type Button; sleep 3
}
funnel() {
  xcrun simctl terminate "$U" ai.jef.browser 2>/dev/null; sleep 2
  xcrun simctl launch "$U" ai.jef.browser >/dev/null; sleep 4
  printf '%s' "https://www.aerolineas.com.ar/flex-dates-calendar?adt=1&inf=0&chd=0&flexDates=true&cabinClass=Economy&flightType=ROUND_TRIP&leg=BUE-COR-20261025&leg=COR-BUE-20261030" | xcrun simctl pbcopy "$U"
  axe tap -x 201 -y 811 --udid "$U" >/dev/null
  axe key-combo --modifiers 227 --key 4 --udid "$U" >/dev/null
  axe key-combo --modifiers 227 --key 25 --udid "$U" >/dev/null; sleep 1
  axe key 40 --udid "$U" >/dev/null; sleep 45
  if W | grep -q "\[btn\] Aceptar"; then T "Aceptar" --type Button; sleep 20; fi
  T "Continuar" --type Button; sleep 40
  # By date only: the button's label carries the fare, and the fare changes.
  local day; day=$(W | grep -m1 "\[btn\] 29 de octubre de 2026" | sed -E 's/^ *[0-9]+ \[btn\] (.*[^ ]) *(\(.*\))?$/\1/')
  if [ -z "$day" ]; then echo "no hay botón para el 29 de octubre"; W | grep "octubre de 2026" | head -3; return 1; fi
  T "$day" --type Button; sleep 25
  T "Ver vuelos" --type Button; sleep 50
  local l f
  l=$(W | grep -m1 "2 de 7\." | sed -E 's/^ *[0-9]+ \[btn\] (.*)  \(Elige esta opción en la página\)$/\1/'); T "$l"; sleep 40
  f=$(W | grep "Apareció al tocar" -A 1 | sed -n 2p | sed -E 's/^ *[0-9]+ \[btn\] (.*)  \(Activa.*$/\1/'); T "$f" --type Button; sleep 50
  l=$(W | grep -m1 "1 de 7\." | sed -E 's/^ *[0-9]+ \[btn\] (.*)  \(Elige esta opción en la página\)$/\1/'); T "$l"; sleep 40
  f=$(W | grep "Apareció al tocar" -A 1 | sed -n 2p | sed -E 's/^ *[0-9]+ \[btn\] (.*)  \(Activa.*$/\1/'); T "$f" --type Button; sleep 50
  T "Comprar" --type Button; sleep 45
  T "Aceptar" --type Button; sleep 60
  # The passenger form renders late in the simulator (a minute or more
  # after the route changes). The late-change observer should bring it in
  # on its own; "Leer de nuevo" is the fallback, and using it is reported.
  local waited=0
  while ! W | grep -q "\] Nombre" && [ $waited -lt 150 ]; do sleep 15; waited=$((waited + 15)); done
  if W | grep -q "\] Nombre"; then echo "formulario llegó solo, ~${waited}s después de los 60s"; else T "Leer de nuevo" --no-scroll; sleep 25; echo "formulario sólo con Leer de nuevo"; fi
  echo "=== checkout ==="; W | grep -c "field\]"
}

passenger() {
  type_into "Nombre" "Ana"
  type_into "Apellido" "Perez"
  pick "Día" "15"
  filter_pick "Mes" "oct" "Octubre"
  filter_pick "Año" "1990" "1990"
  T "Género" --type TabGroup --at 0.25; sleep 2
  pick "Tipo de Documento" "DNI"
  type_into "nro documento" "30123456"
  # Picking the document type adds its expiry date to the form; the
  # late-change observer brings the new fields in a few seconds later.
  local waited=0
  while ! W | grep -q "\] Día de vencimiento" && [ $waited -lt 30 ]; do sleep 5; waited=$((waited + 5)); done
  echo "vencimiento visible tras ${waited}s"
  pick "Día de vencimiento" "15"
  filter_pick "Mes de vencimiento" "dic" "Diciembre"
  filter_pick "Año de vencimiento" "2030" "2030"
  paste_into "Email" "ana.perez@example.com"
  paste_into "Confirmá tu email" "ana.perez@example.com"
  T "Teléfono" --type TabGroup --at 0.25; sleep 2
  type_into "contactInformation_areaCode" "11"
  type_into "contactInformation_phoneNumber" "45678901"
  local box; box=$(W | grep -i "CheckBox\].*\(condicion\|término\|acepto\)" | head -1 | sed -E 's/^ *[0-9]+ \[AXCheckBox\] (.*)  = .*$/\1/')
  if [ -n "$box" ]; then T "$box"; sleep 2; else echo "sin casilla de condiciones"; fi
  echo "=== formulario lleno ==="; W | grep -n "field\]\|TabGroup\|Toggle\|Switch" | head -30
  T "Siguiente" --type Button; sleep 45
  echo "=== después de Siguiente ==="; W | grep -n "\[H\]\|Aviso\|Error en\|field\]\|Siguiente\|Pagar\|Apareció" | head -40; W | tail -1
}

case "${1:-}" in
  funnel) funnel ;;
  passenger) passenger ;;
  *) echo "uso: $0 funnel|passenger"; exit 2 ;;
esac
