# Cómo probar JEF Browser

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
