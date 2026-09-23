# Diagnóstico después de probar en el iPhone — 2026-09-23

Registro pedido por Daniel antes de lanzar una auditoría con otro modelo. No
propone cambios nuevos: deja escrito qué está mal, con evidencia, y cómo
quiere Daniel que se trabaje. Las notas de cada prueba están en
[notas-daniel.md](notas-daniel.md); la arquitectura acordada, en
[propuesta-arquitectura.md](propuesta-arquitectura.md); la auditoría de reglas
del 22/9, en [auditoria-hardcodeo.md](auditoria-hardcodeo.md).

Estado del código: rama `f1-arquitectura`, commit `c07640a` (es lo instalado
en el iPhone de Daniel). `main` está en `a3a830e`.

## 1. Demasiadas restricciones

Daniel: *"¿Por qué seguimos teniendo reglas viejas? Todas las reglas traen
problemas. Para eso está el modelo, para interpretar. Nuestras reglas sólo
ponen restricciones, y hay miles de millones de websites: siempre vamos a
estar pisando alguna. Tenemos que basarnos en cosas universales."*

**Cuántas hay.** La auditoría del 22/9 encontró **267 reglas cableadas**
(Assistant.swift 145 hallazgos, extract.js 50, Answerer.swift 30, Router.swift
17, resto 42): 67 umbrales mágicos, 47 textos fijos, 43 atadas al castellano,
31 seguros, 29 parches sobre otro sistema, 22 para un sitio en particular, 16
atadas a Argentina, 12 atajos. Recomendaba: 180 a código genérico, 45 al
modelo, 36 quedan (seguros o decisiones), 6 se sacan.

**Cuántas se sacaron desde entonces:** pocas. Las cabezas `kind` y `move` de
Jev, las listas de palabras de `isSearch` y de `candidates`, el mínimo de 5
letras, `inferredName` de extract.js.

**Cuántas se agregaron** en F1 y F2 (22 y 23/9), para arreglar casos:

| Regla | Dónde | ¿Universal? |
|---|---|---|
| Umbrales de Jev: compromete 0,2 · cual_confianza 0,5 · cual_seguir 0,8 · esta_si 0,75 · esta_no 0,35 · nombre_control 0,6 · anuncio 0,7 | criterios.json | Números: hay que medirlos, no son universales |
| Lista cerrada de 7 tipos de ruido | criterios.json | Es una decisión de diseño |
| Todo formulario de la página va primero como «Completar…» / «Pulsar…» (ya existía; en F1 dejó de excluir los buscadores) | Assistant `closeTurn` | **No.** Es la regresión que vio Daniel en ANSES |
| Un link a la misma dirección no es un paso | Assistant `leadsAway` | Sí (URL) |
| Después de moverse, lo que no es un paso seguro es haber llegado | Assistant `run` | Restricción |
| En la página del buscador sólo se abren resultados | Assistant `openable` | Restricción |
| El título de una tarjeta es el primer título visible; la dirección que muestra el link se guarda aparte | extract.js `itemOf` | Sí (visibilidad, URL) |
| Las opciones de una pregunta, de a 4, en el orden de la página | Assistant | Presentación |
| La pregunta de Gemini tiene que nombrar sus propios botones | Assistant `names` | Verificación |
| Si el contenido no ofrece nada, el menú es la página | Assistant `candidates` | **Restricción** (heurística) |
| "Abrir" que no encuentra busca afuera con el nombre del sitio | Assistant `run` | Restricción |
| Si el ruteador pide escribir y no hay formulario: la tarea espera / se busca | Assistant `carry` | Restricción |
| Una dirección escrita por el ruteador se busca por su sitio | Assistant `arrive` | Parche sobre el modelo |
| Si al buscar carga otra cosa que resultados, se cuenta lo que hay | Assistant `arrive` | Sí (URL) |

**Lo que Daniel pide:** en el código sólo lo universal: los estándares (HTML,
ARIA, URL), los seguros para la persona (no pagar ni confirmar solo, no
escribir un dato que no dijo, no decir una cifra que no está en la página) y
que siempre haya una salida (Volver, Otra cosa). Todo lo demás lo interpreta el
modelo.

## 2. La cadena que no está integrada

Daniel: *"Es un conjunto de factores. Tenemos que capturar mejor cuál es la
intención del usuario, cuál es el contexto que nos da la website, y en base a
ese contexto cuál es la lista de opciones probables o próximos pasos. Somos un
asistente proactivo: tenemos que ahorrar pasos al usuario. Ahí estamos
fallando: en la conexión entre intención, contexto que trae la website,
elementos que dispone la website y cómo se lo mostramos al usuario."*

| Eslabón | Qué debería pasar | Qué pasa hoy (evidencia: ANSES en el iPhone) |
|---|---|---|
| **1. Intención** | «Quiero sacar un turno en ANSES» queda grabado hasta que la persona declare otra cosa | JEF sólo recuerda el último mensaje escrito (`lastRequest`); un «volvé» y la intención se pierde. La tarea persistente es la fase F4, sin hacer |
| **2. Contexto** | Entender qué es la página y para qué sirve respecto de la intención | Gemini la mira al llegar, sin razonamiento (`reasoning_effort: none`) |
| **3. Elementos** | Todo lo que la página ofrece, ordenado por lo más probable para la intención | El código pisa el orden de Gemini: formularios primero, los botones sueltos antes que las listas (`options(of:)`) |
| **4. Cómo se muestra** | Pocos próximos pasos, en el idioma de la persona, sin tecnicismos; si hay que elegir, una pregunta | En turnos de ANSES: «Completar «buscador»» y «Pulsar «Search»», dos botones técnicos para lo mismo; «Sacar turno en Anses» contestó con instrucciones ("debes ingresar a anses.gob.ar…") en vez de llevar; antes, "está en la lista como número 4" |

Cómo lo imagina Daniel: con la intención declarada, JEF escanea la página y
propone lo más probable. En ANSES: "ANSES muestra una lista de N servicios;
escribime para cuál querés sacar turno, o abajo tenés las opciones", y también
"Buscar algo en ANSES" como una sola opción. Hay sitios donde lo probable es
buscar (Amazon, Mercado Libre) y otros donde es elegir de una lista (ANSES).
Daniel abrió la puerta a subir "un poquito" el razonamiento de Gemini para ese
escaneo.

El buscador de un sitio, según Daniel: una sola opción que diga lo que hace
—«Buscar en Mercado Libre», «Buscar en La Nación»—; si la persona la toca, se
sabe que va a buscar. No dos botones ni "Pulsar «Search»".

## 3. Quién hace qué (lo que se habló)

| | Cuándo | Qué |
|---|---|---|
| **Gemini** | Una vez al llegar a cada página, y cuando hay que entender o redactar | La intención, la lectura de la página, el orden de los próximos pasos y cómo se dicen; contestar; la zona gris |
| **Jev** | En cada pedido, en fracciones de segundo | ¿Cuál? (lo que la persona escribe, entre los elementos) · ¿Está? · ¿Compromete? · ¿Es anuncio? · nombrar botones sin etiqueta |
| **Código** | Siempre | Ejecutar (tocar, escribir), los estándares, los seguros y la salida |

Cuando la persona toca un botón no hace falta ningún modelo. Cuando escribe,
primero Jev; Gemini sólo si Jev duda.

## 4. Errores que marcó Daniel hoy

Detalle en [notas-daniel.md](notas-daniel.md):

1. Las sugerencias del inicio están cableadas (deuda).
2. Google sin resultados en ANSES — arreglado (extractor).
3. ANSES: le ofrecía consultar un turno cuando quería sacarlo; "número 4" —
   arreglado a medias (pregunta por el trámite; la intención sigue sin
   grabarse).
4. «Ir a turnos» abría las imágenes de Google — arreglado.
5. El buscador del sitio, duplicado y en lenguaje técnico — **sin arreglar**
   (regresión de F1, sección 1).
6. «Sacar turno en Anses» contestó con instrucciones sacadas de Google en vez
   de llevar a la persona — **sin arreglar** (el ruteador llena "question" en
   un pedido de hacer algo).
7. El tuteo, y cómo habla JEF según el país — deuda.

## 5. Cómo quiere Daniel que se trabaje

- **Un cambio por vez**, sólo sobre lo que él marca al usar la app, y decirle
  antes qué se va a tocar.
- **Sin rondas de jueces ni bancos nuevos** por iniciativa propia: "todo eso
  trae ruido".
- **No reparar casos tocando prompts.** Si se puede en el código, va en el
  código; si no, se decide con él.
- **Cada prueba en un sitio distinto**, de otro país, sin repetir: "después un
  usuario en México no va a funcionar para nada, porque siempre practicamos
  con ANSES o con Banco Nación".
- **Foco en la navegación real:** no perseguir lo que produce el entorno de
  prueba (permisos del simulador, el captcha de Google por tantas búsquedas,
  guiones que nadie haría). "Estamos en MercadoLibre.com, hay una lista de
  países. ¿Qué país quiere seleccionar? Punto."
- Cada vez que se toca algo, él lo vive como "siempre empeora": comparar
  contra la versión de la mañana o del día anterior, con el registro de su
  iPhone.
