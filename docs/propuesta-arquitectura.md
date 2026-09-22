# Propuesta de arquitectura — Gemini, Jev y código

2026-09-22. Acordada con Daniel. Reemplaza el reparto anterior, en el que
Gemini y Jev decidían lo mismo con media información cada uno y nadie
verificaba el resultado.

## El problema que resuelve

En bna.com.ar, "quiero ir a mi home banking": Gemini decidió "abrir" viendo el
texto de la página pero no la lista de lo que se puede tocar; Jev vio la lista
pero no el texto, y no tenía la opción "no está acá", así que eligió seguro
«Canales Electrónicos» (un menú). Nadie verificó la llegada y nadie recordaba
que dos pasos antes los resultados del buscador traían el home banking.
Callejón sin salida.

## Las reglas

1. **El código no lee palabras.** Sólo estándares: HTML y ARIA (`type`, `role`,
   `autocomplete`, `rel`), URL y dominios, listas públicas mantenidas (EasyList,
   Public Suffix List), el DOM (visible, cambió). Todo lo que exige entender un
   texto, en cualquier idioma, es de un modelo.
2. **Gemini mira a la persona, Jev mira la página, la persona decide lo que
   tiene consecuencias.**
3. **Nunca un callejón sin salida:** todo turno sin resultado ofrece una salida.

## Quién hace qué

| | Mira | Hace |
|---|---|---|
| **Gemini** | La persona | Qué quiere, si sigue la tarea o es otra, qué buscar o escribir (con qué palabras), el plan B si no está en la página, y lo que se dice. Al llegar, en esa misma llamada, **filtra el ruido**: qué se sugiere y qué no |
| **Jev** | La página | **Navegar entre los botones:** cuál lleva a lo pedido o «ninguno», ¿está?, ¿compromete?, ¿llegó?. Y qué tipo de botón es uno sin etiqueta |
| **Código** | Las reglas | Estándares (deciden solos cuando alcanzan; si no, van a Jev como datos), umbrales, la carrera Jev–Gemini, garantías |
| **Persona** | Las consecuencias | Pagar, confirmar, cookies, desempates |

Medido el 2026-09-22 sobre 12 páginas reales en 5 idiomas (`Scripts/probar-jev.py`):
navegar con Jev tarda ~1,0 s típico contra ~1,35 s de Gemini, cuesta 4 veces
menos y sabe cuándo duda (con confianza ≥ 0,5 coincidió con Gemini 8 de 10, y
en uno de los dos desacuerdos acertó Jev). Filtrar con Jev, en cambio, exige
muchos pedidos por página y el proveedor los rechaza: el filtro va con Gemini,
en la llamada que ya existe. El filtro de Gemini sólo decide qué se sugiere;
la navegación de Jev sigue viendo todos los elementos.

**La carrera:** se pregunta a Jev; si en ~1 s no contestó, se larga Gemini. El
gateway llegó a tardar 27 y 61 s en reintentos: con la carrera el peor caso es
~2,5 s.

## Las etiquetas

- **Con etiqueta:** la del sitio, tal cual, sin traducir ("Login" es "Login").
- **Sin etiqueta:** JEF le pone nombre, en el idioma de la persona, porque es
  la voz de JEF. El código junta las pistas del HTML (clase, `id`, título del
  ícono, región); Jev elige el tipo entre una lista cerrada (cerrar, menú,
  buscar, cuenta, carrito, volver…, u "otro"); el nombre sale del catálogo de
  frases de JEF. Si Jev dice "otro" o duda, lo nombra Gemini al llegar; si
  tampoco sabe, no se ofrece. Reemplaza a `inferredName` de extract.js, que
  adivina con palabras en castellano e inglés y nombra siempre en castellano.

El modelo local de Apple (Foundation Models) se midió y hoy no sirve de juez:
contestó "compromete" a "Buscar" y a "Ver más", su filtro bloqueó páginas
normales y no cubre árabe, hindi ni ruso. Queda para volver a medir.

## El turno

```
AL LLEGAR   Código: mapa + estándares → Jev: nombra los botones sin etiqueta
            → Gemini: filtra el ruido y cuenta dónde está, en una sola llamada

EN CADA PEDIDO
            Gemini (intención + plan B)  ‖  Jev (¿cuál? / ninguno / ¿está?)
            (si Jev no contesta en ~1 s, decide Gemini: la carrera)
            → el código combina, en cascada por confianza:
              estándar → Jev → Gemini (zona gris) → persona (si tiene consecuencias)
            → Jev: "¿compromete?" antes de tocar solo · "¿llegó?" después
```

Adónde escala cada duda depende de cuánto cuesta equivocarse: ruido y
relevancia a Gemini; lo que tiene consecuencias, a la persona; lo barato no
escala (un buscador dudoso se trata como formulario común y el botón lo toca
la persona).

## Prompts

**Un prompt es una estructura fija, como un JSON, inmutable a un caso
particular** (Daniel, 2026-09-22): quién es el modelo, las reglas globales
(hablar en el idioma de la persona, usar sólo el texto de la página, no
inventar), qué recibe y qué devuelve (su esquema). **Nunca se repara un caso
agregando una frase:** así el prompt se vuelve una bola gigante. Lo que falla
se arregla en los datos (`criterios.json`, `decisiones.json`), en el esquema
de la respuesta o en el código que verifica.

Pasó en F1: una aclaración escrita sobre el ruido siguió fallando 2 de 8; lo
que lo arregló fue un campo del esquema —cada marca de ruido dice su `tipo`,
de una lista cerrada, y la que no tiene tipo válido no cuenta— con 0 de 8. La
aclaración se sacó.

Hecho en F1: los seis prompts de Gemini (ruteador, contestar, resumir,
orientar, reinterpretar, valor) viven en `Sources/Intelligence/prompts.json`
con estructura fija, respuesta por `json_schema`, en inglés (universal) y sin
los parches de casos (horas de coberturas en vivo, el orden compra/venta de
una cotización, "sacar un turno", la regla tú/vos). La app los arma con
`Prompts.swift` y los tests con `Scripts/prompts_gemini.py`, igual.

Medido en las 60 intenciones con respuesta esperada (`probar-ruteo.py
--corridas 3`): el prompt de antes daba 92 %; **reescribirlo** al limpiarlo lo
bajó a 81 %; la **traducción fiel** del texto de siempre da 91 %, con más
decisiones estables (50 de 60). Limpiar es sacar lo que no es global, no
reescribir: la redacción de una regla importa ("el asistente lo busca en la
página", dentro de abrir, es lo que evita salir a buscar afuera lo que está
en la portada).

## Dominios oficiales

Un dominio de gobierno (`.gob.ar`, `.gov`, `.gouv.fr`, `.go.jp`…) no se puede
registrar sin serlo: es una señal que un sitio trucho no puede copiar. Se usa
sólo a favor, nunca en contra (PAMI, Banco Nación y Correo Argentino son
oficiales y no son `.gob`). Los datos salen de fuentes públicas por script
(Public Suffix List, la lista oficial de `.gov` de EE. UU., `.int`,
`.europa.eu`) a `dominios-oficiales.json`. El orden de Google se respeta
siempre; si aparece un sitio de gobierno, puede subir en el ranking (cómo,
queda para resolver más adelante, Daniel 2026-09-22). Se dice en los
resultados ("sitio del gobierno"), se usa en la salida y va como dato a Jev. Lo
oficial que no es gobierno (bancos, empresas, clubes) queda para más adelante,
con Wikidata.

## Decisiones de Daniel (2026-09-22, después de F1)

- **Al llegar, como hoy:** un resumen de la página donde se está y los
  botones con los próximos pasos. Lo que no va es hablar de la mecánica
  interna: nunca "el botón está en el número 4 de la lista". Los números de
  la lista son sólo para que el modelo elija; se arregla por estructura
  (ids opacos y la lista descripta como interna), no con una frase.
- **Primero la página, después afuera.** Con una página abierta, lo pedido se
  busca primero en ella (Jev: ¿está?, ¿cuál?; Gemini: contestar con la
  página) y sólo si no está se busca en Google, con el nombre del sitio. Salvo
  que la persona nombre otro sitio: eso es ir.
- **Los pop-ups de promoción los cierra JEF**, y dice qué decían.
- **Los resultados orgánicos no se juzgan.** Si Google pone primero a un
  intermediario, ese es el resultado: JEF no decide qué le conviene buscar a
  la persona. Lo que sí hace: no contar los anuncios como resultados, darle
  a cada botón lo que Google muestra (título, sitio y su descripción) para
  que la persona decida, y que lo que JEF nombra al contestar esté entre los
  botones.
- **Anuncios en los resultados:** en Boca, los tres primeros botones eran
  anuncios de reventa ("Resultados patrocinados"); el filtro por direcciones
  de Google (`aclk`, `googleadservices`) dejó de andar. Lo reemplaza Jev
  juzgando "¿es un anuncio?" por resultado, con la sección donde está como
  contexto, en cualquier idioma. Junto con la prioridad de los dominios
  oficiales.

## Cuidados

- **Referencias** ("la segunda", "esa"): las resuelve Gemini. Si apuntan a un
  botón ofrecido se usa ese número; si no, segunda consulta a Jev.
- **Resultados del buscador:** Jev filtra, no reordena. El orden es el del
  buscador (decisión de Daniel).
- **Caché por elemento** (texto + destino + región), no por dirección: los
  menús y las páginas que cambian sin cambiar de dirección la invalidan.
- **Escala:** Jev tiene 1.200 pedidos por minuto por cuenta y el gateway dio
  503 con pedidos grandes. Tandas de ~35 preguntas en paralelo, tiempo máximo
  (si Jev no contesta, el turno sigue con estándares), y un backend con caché
  compartida antes de publicar.
- **Inyección:** Jev no resiste texto malicioso. Si lo elegido sale del dominio
  del sitio, se dice y se confirma.
- **Idiomas:** Jev rinde mejor en inglés. En otro idioma baja la confianza y se
  deriva más a Gemini: más caro, no peor. Se mide por idioma.
- **Privacidad:** Gemini por la API paga (en la gratuita Google puede usar los
  datos). Jev con retención cero. Los valores de los campos nunca viajan.

## Fases

| | Qué |
|---|---|
| **F0** | Banco de pruebas multilingüe: medir tiempo y costo, etiquetar, calibrar umbrales |
| **F1** | Candados; Gemini filtra el ruido al llegar; ids únicos de campos; Jev nombra los botones sin etiqueta (en lugar de `inferredName`) |
| **F2** | Gemini para la intención con plan B, Jev para navegar con la carrera; se borran `kind`, `move`, `reinterpret` y las listas de palabras; prompts como JSON de estructura fija, sólo con reglas globales; dominios oficiales; si Gemini nombra un sitio, ese resultado se ofrece |
| **F3** | Verificación con Jev, la salida y los avisos según su tipo |
| **F4** | La tarea persistente |
| **F5** | Backend (claves, caché compartida, límites de uso), antes de TestFlight |
| **Aparte** | La voz: un mensaje escrito entero con el foco de VoiceOver |

## Cómo se prueba

`Scripts/probar-jev.py`: pocos casos por vez, en cualquier idioma, con los
mismos criterios que usa la app (`Sources/Intelligence/criterios.json`).
Los casos los propone Gemini y se guardan en `Tests/multilingue/casos.json`;
cada corrida toma una muestra distinta. Jev se compara con el Gemini de la
app (3.1 Flash-Lite) y Daniel revisa sólo los desacuerdos.
