# Cómo probar JEF Browser

## La prueba que manda: pedir cosas reales

Una respuesta se da por buena cuando se hizo el pedido de punta a punta en la
app —en el simulador o en el teléfono—, no leyendo el código. Los bugs que
importan aparecieron así: el asistente deshabilitado al abrir, el ruteador
salteado en el primer turno, ANSES terminando en Francia, el pie de La Nación
leído como si fueran los titulares.

Para cada pedido, dos preguntas:

1. **¿Llegó a donde se pidió, o dijo por qué no?** Un silencio, o una página
   que cambió sin que nadie lo pidiera, es un bug.
2. **¿Lo que dijo es cierto?** Contrastarlo con la página, que está a la vista
   arriba. Una respuesta sin cita verificada, un titular que no está, un
   número que no coincide: bug.

Pedidos que ya encontraron algo: «llevame a la nación», «dame los titulares»,
«volvé», «¿a cuánto está el dólar?», «quiero entrar a anses y pedir un turno»,
«entrá a mercado libre y comprame pilas», «busca Buenos Aires» parado en
Wikipedia. Las 60 de `Tests/intenciones.json` se corren contra el ruteador
con `./Scripts/probar-ruteo.py`.

**Configurar la región del simulador antes de probar**: el buscador ordena por
país, y con el simulador en `en_US` "anses" termina en anses.fr.

```bash
xcrun simctl spawn <udid> defaults write .GlobalPreferences AppleLocale es_AR
```

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
| Dos dedos, Z | Volver a la página anterior |

**Lo que hay que probar:** escuchar lo que el asistente dice mientras trabaja,
llegar a los botones que ofrece, y pasar de la página a la conversación. Con
el rotor en "Encabezados", "Asistente" es el salto directo a la conversación.

## Si algo falla

**"Untrusted Developer"** → confiar en el certificado (arriba).

**El asistente no entiende nada o dice "sin conexión"** → falta la key o no
llega. Corré `./Scripts/make-secrets.sh`, volvé a buildear, y verificá la key:

```bash
cd "/Users/daniel/Developer/JEF- BROWSER" && set -a && . ./.env && set +a && curl -s https://ai-gateway.vercel.sh/v1/credits -H "Authorization: Bearer $AI_GATEWAY_API_KEY"
```

## Sobre TestFlight

Todavía no. TestFlight sirve cuando quieras que lo pruebe otra persona —
alguien que use VoiceOver a diario, que es el feedback que de verdad importa y
el que todavía no hubo. Antes hay que sacar la key del binario (ver "Deuda
conocida" en el README).
