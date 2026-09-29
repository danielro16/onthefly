# Botones de relleno: la lista de palabras contra las reglas de forma

2026-09-28. 88 sitios (los de las mediciones de avisos, formularios y
titulares), leídos con `Scripts/read-page.js` tres veces: con la lista de
palabras (antes), sin la lista y sin reglas (sin), y con las reglas de forma
con un registro de cada control que esconden (forma). Los datos crudos se
perdieron al reiniciarse la sesión; queda este resumen.

## Lo que escondía la lista (antes contra sin, 86 sitios leídos en los dos)

| Palabras | Escondidos | Qué eran |
|---|---|---|
| «ir a / skip to / saltar a» | 20 | 3 links de salto (Aerolíneas, El Mundo ×2). Los demás, links reales: «Ir a Mi Argentina», «Ir a videos» (TN), «Ir a la tienda» y «Ir a la página 2/3/5» (braille.pe), «Ir a Foodit», «Ir a RSS», «Ir a la app» (LATAM), «Ir a la página principal» |
| «anterior / siguiente / previous / next» | 15 | Flechas de carrusel (Página/12, 20minutos, Corona) |
| botones de cookies | 9 | Botones de un segundo aviso, debajo de una verificación de edad o un selector de país (Jack Daniel's, Corona, Johnnie Walker, IKEA, Bacardi) |
| «ok / got it / entendido» | 2 | Botones reales que cierran un aviso (Airbnb, TikTok) |

## Lo que esconden las reglas de forma (registro, 83 sitios)

- **Carrusel, 46:** flechas y pausas de Página/12, IKEA («Ver siguientes
  artículos»), Hennessy, Corona, 20minutos, Repubblica, Folha, Frávega,
  Clarín, TN, Trenitalia, Jägermeister, La Vanguardia, Airbnb («scroll tabs
  forward»), Aerolíneas.
- **Salto, 6:** Aerolíneas («Ir a contenido principal»), El Mundo
  («Saltar a navegación principal», «Saltar a contenido»), Johnnie Walker
  («Skip navigation and focus on main content»).
- **Otro aviso, 14:** los botones de cookies de un segundo aviso.

Antes de ajustarlas, las reglas escondían también botones de menú (El Mundo,
The Guardian, Absolut, Johnnie Walker), los botones de sección de Wikipedia,
el buscador de wikipedia.org y los links de un panel cerrado de Xataka. Se
ajustaron: el control de carrusel no está en la cabecera ni en el menú, no
declara abrir algo (aria-expanded, aria-haspopup), no es de un formulario ni
un link; si declara qué mueve (aria-controls), lo que mueve tiene que ser una
tira que se desplaza (los «mehr» de Welt). El link de salto está antes del
contenido y lleva al contenido o a un control.

## En la app

- `mi-argentina`: «entrá a Mi Argentina» abre «Ir a Mi Argentina»
  (mi.argentina.gob.ar → ingreso en id.argentina.gob.ar).
- `bloqueo-lanacion`: igual que antes.
- `cookies-aerolineas`: cookies aceptadas (0,80 y 0,90 con la rama; 0,91 y
  0,94 con main). En la primera corrida Jev no estuvo seguro del tipo de aviso
  y se preguntó «cerrar»; no se repitió. Aparte, y también con main (1 de 2)
  y sin la relectura por párrafo (1 de 2): el carrusel de ofertas cambia su
  texto cada 3 a 5 s, JEF lo toma como página nueva, vuelve a empezar dos
  veces y termina en la descripción de plantilla («Clase: 4. Los tres
  primeros:»). Error viejo, anotado aparte.
