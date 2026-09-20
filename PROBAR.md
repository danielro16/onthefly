# Cómo probar JEF Browser

## La prueba que manda: original contra accesible

Pedido de Daniel, 2026-09-20. **Antes de dar por buena cualquier pantalla hay
que recorrerla entera, control por control, y compararla con la página
original.** No alcanza con que el recorrido salga lindo en el extractor: lo
que se mide es lo que una persona puede hacer.

Dos preguntas, y las dos se contestan recorriendo:

1. **¿Se perdió algo?** Todo lo que la página original ofrece tiene que estar
   en la versión accesible. Agrupado sí —detrás de una puerta, dentro de una
   lista, en un cajón—, pero **presente y alcanzable**. Si algo está en el
   original y no aparece en ningún lado de la versión accesible, es un bug,
   no una simplificación.
2. **¿Se puede navegar?** Cada cosa que se toca tiene que hacer lo que dice.
   Un botón que no responde es peor que un botón que no está: la persona lo
   escucha, lo activa, y no pasa nada.

El método, para cada sitio:

- Abrir la misma URL en las dos vistas. El botón **Original / Accesible** de
  la barra de abajo alterna entre las dos sin recargar ni perder la sesión.
- Recorrer la versión accesible de arriba abajo, **tocando cada control** y
  volviendo. Abrir cada puerta, y adentro de cada puerta, cada caja.
- Anotar, por cada control: qué dice, qué hizo, y qué hace el equivalente en
  el original.
- Lo que falta y lo que no responde son las dos listas que importan.

Sin simulador se puede adelantar la mitad con `./Scripts/read-page.js`: dice
qué entrega el extractor y cuántos titulares del original llegaron. **No
reemplaza esta prueba** — Chrome avanza animaciones y frames que un WKWebView
oculto congela, así que un botón puede andar ahí y no en la app. Eso pasó con
el menú de La Nación.

### Botones que no responden — abierto

Reportado sobre lanacion.com.ar: el menú hamburguesa y "Secciones" no hacen
nada. "Secciones" quedó andando al hacer que las transiciones CSS terminen de
una mientras el WebView no se ve (`8f4cd01`), pero **el reporte es posterior a
eso**, así que hay al menos un caso más. Sospechas por orden de probabilidad:

1. Un control que el sitio dibuja como `<div>` sin rol, así que ni siquiera se
   reporta como acción.
2. Un control que necesita un gesto real (`pointerdown`/`touchstart`) y no el
   `click()` que `__jefActivate` dispara.
3. Un control cuyo panel aparece, pero fuera del alcance del recorrido.

## En tu iPhone (lo que importa)

El simulador **no corre VoiceOver**. Trae un inspector de accesibilidad, que
sirve para verificar que las etiquetas existan, pero no para sentir la
navegación. Y la navegación es el producto. Así que probá en el teléfono.

Tu iPhone 15 Pro ya está pareado y la firma quedó configurada (team
`4SXUH7L36N`, automática).

```bash
./Scripts/make-secrets.sh && xcodegen generate && open JEFBrowser.xcodeproj
```

1. Conectá el iPhone por cable (la primera vez, después anda por WiFi)
2. En Xcode, arriba, elegí tu iPhone en el selector de destino
3. **⌘R**

La primera vez el iPhone va a pedir confiar en el certificado:
**Ajustes → General → VPN y gestión de dispositivos → Apple Development → Confiar**

## Activar VoiceOver

Lo importante es poder prenderlo y apagarlo rápido sin ver la pantalla:

**Ajustes → Accesibilidad → Función rápida de accesibilidad → VoiceOver**

Queda en triple clic del botón lateral. Prendés, probás, apagás.

### Gestos mínimos

| Gesto | Qué hace |
|---|---|
| Swipe derecha / izquierda | Elemento siguiente / anterior |
| Doble toque | Activar lo que está seleccionado |
| **Rotor: dos dedos girando** | Cambiar modo de navegación |
| Swipe arriba / abajo | Moverse según el rotor |
| Dos dedos, swipe arriba | Leer todo desde arriba |

**El rotor es lo que hay que probar.** Giralo hasta "Encabezados" y hacé swipe
abajo: deberías saltar de sección en sección. Probá también "Enlaces".

## Qué mirar

Comparar contra Safari es la prueba real. Abrí la misma URL en los dos.

1. **Contá los swipes** hasta llegar a lo que buscabas. Es la métrica del
   proyecto. En `aerolineas.com.ar` medimos ~224 paradas en Safari.
2. **Probá el rotor de encabezados.** En Safari, esa página tiene **un solo**
   encabezado — el rotor es inútil. Acá debería haber varios.
3. **Links dentro de un párrafo.** Buscá un párrafo con links y hacé swipe: cada
   link tiene que ser su propia parada. Esto es lo que React Native no puede
   hacer y por lo que la app es nativa.
4. **El panel de intención.** En una aerolínea debería preguntarte qué querés
   hacer. En un artículo de Wikipedia **no** debería preguntarte nada.

## URLs para probar

| URL | Qué debería pasar |
|---|---|
| `es.wikipedia.org/wiki/Buenos_Aires` | Artículo limpio, sin preguntas |
| `aerolineas.com.ar` | Pregunta qué querés hacer |
| Cualquier diario | Mucho ruido, buen caso de prueba |

Para cambiar la URL: tocá la barra de arriba, escribí, Enter.

## Si algo falla

**"Untrusted Developer"** → confiar en el certificado (arriba).

**Se buildea pero no aparece nada** → la app cae al modo v0 si no hay key de
Jev. Corré `./Scripts/make-secrets.sh` y volvé a buildear.

**"No readable content"** → Readability no encontró artículo y la página
tampoco tenía acciones. Pasa en SPAs que cargan todo por JS después.

**El panel no pregunta nunca** → puede ser que Jev esté fallando en silencio.
Verificá la key:

```bash
cd "/Users/daniel/Developer/JEF- BROWSER" && set -a && . ./.env && set +a && curl -s https://ai-gateway.vercel.sh/v1/credits -H "Authorization: Bearer $AI_GATEWAY_API_KEY"
```

## Sobre TestFlight

Todavía no. TestFlight sirve cuando quieras que lo pruebe otra persona —
alguien que use VoiceOver a diario, que es el feedback que de verdad importa.
Para eso hace falta subir a App Store Connect, y conviene hacerlo cuando la
agrupación esté lista: probar con un usuario real una versión que todavía tiene
224 elementos no aporta nada.
