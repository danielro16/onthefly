# solo-botones-clarin

**Quién:** 72 años, perdió la vista hace tres. Escribir le cuesta: prefiere tocar lo que le ofrecen.

**Qué quiere:** Leer alguna noticia de Clarín escribiendo sólo el nombre del sitio y después tocando siempre la primera opción.

Convenciones: 🔊 lo que VoiceOver anuncia solo, con la hora desde el inicio. Un anuncio sin cola corta al que se está diciendo y descarta los que esperaban; uno en cola espera a que termine el anterior. La duración se estima a 14 caracteres por segundo. 💬 lo que queda escrito en la conversación. 🔘 los botones ofrecidos, en el orden en que VoiceOver los recorre. 📄 la página que cargó (su texto, el que ve el asistente, está en paginas/).

## Paso 1 — escribe «clarín»

- [+  6.6s] 💬 Persona: clarín
- [+  6.6s] 🔘 Botones: [Llevame a La Nación] · [¿A cuánto está el dólar hoy?] · [¿Cómo va a estar el tiempo mañana?]
- [+  7.4s] 💬 JEF: Buscando: clarín.
- [+  7.4s] 🔊 «Buscando: clarín.»
- [+ 10.5s] 📄 Cargó https://lite.duckduckgo.com/lite/?q=clar%C3%ADn&kl=ar-es — «clarín at DuckDuckGo» (paginas/01.txt)
- [+ 10.5s] 💬 JEF: Estás en los resultados de «clarín». Los 3 más probables:
- [+ 10.5s] 🔊 «Estás en los resultados de «clarín». Los 3 más probables: 1. Noticias. Últimas noticias de Argentina y el Mundo | Clarín, clarin.com. 2. Clarín - septiembre 21, 2026, kiosco.clarin.com. 3. Clarín (periódico) - Wikipedia, la enciclopedia libre, es.wikipedia.org»
- [+ 10.5s] 🔘 Botones: [Noticias. Últimas noticias de Argentina y el Mundo | Clarín — www.clarin.com] · [Clarín - septiembre 21, 2026 — www.kiosco.clarin.com] · [Clarín (periódico) - Wikipedia, la enciclopedia libre — es.wikipedia.org]
- [+ 10.5s] 🔘 Botones: [Noticias. Últimas noticias de Argentina y el Mundo | Clarín — www.clarin.com] · [Clarín - septiembre 21, 2026 — www.kiosco.clarin.com] · [Clarín (periódico) - Wikipedia, la enciclopedia libre — es.wikipedia.org] · [Otra cosa]

Al terminar el paso (11 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-01.txt, captura en paso-01.jpg):
```
  1 [H] Asistente
  2 [H] Vos: clarín
  3 [txt] Buscando: clarín.
  4 [txt] Estás en los resultados de «clarín». Los 3 más probables:
  5 [btn] Noticias. Últimas noticias de Argentina y el Mundo | Clarín — www.clarin.com  (Primera de 4 opciones.)
  6 [btn] Clarín - septiembre 21, 2026 — www.kiosco.clarin.com
  7 [btn] Clarín (periódico) - Wikipedia, la enciclopedia libre — es.wikipedia.org
  8 [btn] Otra cosa
  9 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 10 [btn] Enviar
```

## Paso 2 — toca el botón 1: «Noticias. Últimas noticias de Argentina y el Mundo | Clarín — www.clarin.com»

- [+ 16.1s] 💬 Persona: Noticias. Últimas noticias de Argentina y el Mundo | Clarín — www.clarin.com
- [+ 16.1s] 💬 JEF: Abriendo clarin.com.
- [+ 16.1s] 🔊 «Abriendo clarin.com.»
- [+ 20.6s] 📄 Cargó https://www.clarin.com/ — «Noticias de Argentina» (paginas/02.txt)
- [+ 22.7s] 💬 JEF: Estás en la portada de Clarin.com.
- [+ 22.7s] 🔊 «Estás en la portada de Clarin.com.»
- [+ 22.7s] 💬 JEF: Las primeras notas:
- [+ 22.7s] 🔊 «Las primeras notas:»  ⟶ en cola: empieza a sonar a los +25.1s
- [+ 22.7s] 💬 JEF: El Gobierno apunta a un gas contaminado como la causa del corte de luz que afectó a casi dos millones de personas, La Secretaría de Energía informó que el problema se produjo en el interruptor L46 de…
- [+ 22.7s] 🔊 «El Gobierno apunta a un gas contaminado como la causa del corte de luz que afectó a casi dos millones de personas, La Secretaría de Energía informó que el problema se produjo en el interruptor L46 de…»  ⟶ en cola: empieza a sonar a los +26.5s
- [+ 22.7s] 💬 JEF: Renunció el secretario de Discapacidad en medio de la interna por los recortes del área en el Presupuesto 2027, Otra salida del Gobierno, Política, Renunció el secretario de Discapacidad en medio de…
- [+ 22.7s] 🔊 «Renunció el secretario de Discapacidad en medio de la interna por los recortes del área en el Presupuesto 2027, Otra salida del Gobierno, Política, Renunció el secretario de Discapacidad en medio de…»  ⟶ DESCARTADO: lo cortó un pedido nuevo antes de que sonara
- [+ 22.7s] 💬 JEF: El Gobierno estima que por la visita del Papa se movilizarán 7 millones de personas y evalúa declarar asueto, Habrá tres misas masivas, Política, El Gobierno estima que por la visita del Papa se…
- [+ 22.7s] 🔊 «El Gobierno estima que por la visita del Papa se movilizarán 7 millones de personas y evalúa declarar asueto, Habrá tres misas masivas, Política, El Gobierno estima que por la visita del Papa se…»  ⟶ DESCARTADO: lo cortó un pedido nuevo antes de que sonara
- [+ 22.7s] 🔘 Botones: [Abrir «El Gobierno apunta a un gas contaminado como la causa del corte de…»] · [Abrir «Renunció el secretario de Discapacidad en medio de la interna por los…»] · [Abrir «El Gobierno estima que por la visita del Papa se movilizarán 7…»] · [Seguir con los titulares] · [Volver a la página anterior] · [Otra cosa]
- [+ 23.0s] 📄 Cargó https://www.clarin.com/ — «Noticias de Argentina» (paginas/03.txt)

Al terminar el paso (13 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-02.txt, captura en paso-02.jpg):
```
  1 [H] Asistente
  2 [H] Vos: clarín
  3 [txt] Buscando: clarín.
  4 [txt] Estás en los resultados de «clarín». Los 3 más probables:
  5 [H] Vos: Noticias. Últimas noticias de Argentina y el Mundo | Clarín — www.clarin.com
  6 [txt] Abriendo clarin.com.
  7 [txt] Estás en la portada de Clarin.com.
  8 [txt] Las primeras notas:
  9 [txt] El Gobierno apunta a un gas contaminado como la causa del corte de luz que afectó a casi dos millones de personas, La Secretaría de Energía informó que el problema se produjo en el interruptor L46 de…
 10 [txt] Renunció el secretario de Discapacidad en medio de la interna por los recortes del área en el Presupuesto 2027, Otra salida del Gobierno, Política, Renunció el secretario de Discapacidad en medio de…
 11 [txt] El Gobierno estima que por la visita del Papa se movilizarán 7 millones de personas y evalúa declarar asueto, Habrá tres misas masivas, Política, El Gobierno estima que por la visita del Papa se…
 12 [btn] Abrir «El Gobierno apunta a un gas contaminado como la causa del corte de…»  (Primera de 6 opciones.)
 13 [btn] Abrir «Renunció el secretario de Discapacidad en medio de la interna por los…»
 14 [btn] Abrir «El Gobierno estima que por la visita del Papa se movilizarán 7…»
 15 [btn] Seguir con los titulares
 16 [btn] Volver a la página anterior
 17 [btn] Otra cosa
 18 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 19 [btn] Enviar
```

## Paso 3 — toca el botón 1: «Abrir «El Gobierno apunta a un gas contaminado como la causa del corte de…»»

- [+ 32.2s] 💬 Persona: Abrir «El Gobierno apunta a un gas contaminado como la causa del corte de…»
- [+ 32.2s] 💬 JEF: Abriendo «El Gobierno apunta a un gas contaminado como la causa del corte de…»
- [+ 32.2s] 🔊 «Abriendo «El Gobierno apunta a un gas contaminado como la causa del corte de…»»
- [+ 34.9s] 📄 Cargó https://www.clarin.com/energia-y-mineria/apagon-masivo-gobierno-apunta-gas-contaminado-edenor-dice-investiga-causa_0_HR6soIpGqI.html — «Apagón masivo: el Gobierno apunta a un gas contaminado como la causa que dejó sin luz a casi dos millones de personas» (paginas/04.txt)
- [+ 37.4s] 💬 JEF: Estás en una nota de Clarín sobre el apagón masivo que dejó sin luz a casi dos millones de personas. El Gobierno apunta a un gas contaminado como causa, mientras Edenor investiga el origen del desperfecto.
- [+ 37.4s] 🔊 «Estás en una nota de Clarín sobre el apagón masivo que dejó sin luz a casi dos millones de personas. El Gobierno apunta a un gas contaminado como causa, mientras Edenor investiga el origen del desperfecto.»
- [+ 37.4s] 🔘 Botones: [Leer la nota] · [Resumir la nota] · [Abrir «Clave Única PAMI: qué es, para qué sirve y quiénes deben registrarse»]
- [+ 37.4s] 🔘 Botones: [Leer la nota] · [Resumir la nota] · [Abrir «Clave Única PAMI: qué es, para qué sirve y quiénes deben registrarse»] · [Volver a la página anterior] · [Otra cosa]

Al terminar el paso (14 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-03.txt, captura en paso-03.jpg):
```
  1 [H] Asistente
  2 [H] Vos: clarín
  3 [txt] Buscando: clarín.
  4 [txt] Estás en los resultados de «clarín». Los 3 más probables:
  5 [H] Vos: Noticias. Últimas noticias de Argentina y el Mundo | Clarín — www.clarin.com
  6 [txt] Abriendo clarin.com.
  7 [txt] Estás en la portada de Clarin.com.
  8 [txt] Las primeras notas:
  9 [txt] El Gobierno apunta a un gas contaminado como la causa del corte de luz que afectó a casi dos millones de personas, La Secretaría de Energía informó que el problema se produjo en el interruptor L46 de…
 10 [txt] Renunció el secretario de Discapacidad en medio de la interna por los recortes del área en el Presupuesto 2027, Otra salida del Gobierno, Política, Renunció el secretario de Discapacidad en medio de…
 11 [txt] El Gobierno estima que por la visita del Papa se movilizarán 7 millones de personas y evalúa declarar asueto, Habrá tres misas masivas, Política, El Gobierno estima que por la visita del Papa se…
 12 [H] Vos: Abrir «El Gobierno apunta a un gas contaminado como la causa del corte de…»
 13 [txt] Abriendo «El Gobierno apunta a un gas contaminado como la causa del corte de…»
 14 [txt] Estás en una nota de Clarín sobre el apagón masivo que dejó sin luz a casi dos millones de personas. El Gobierno apunta a un gas contaminado como causa, mientras Edenor investiga el origen del desperfecto.
 15 [btn] Leer la nota  (Primera de 5 opciones.)
 16 [btn] Resumir la nota
 17 [btn] Abrir «Clave Única PAMI: qué es, para qué sirve y quiénes deben registrarse»
 18 [btn] Volver a la página anterior
 19 [btn] Otra cosa
 20 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 21 [btn] Enviar
```

## Paso 4 — toca el botón 1: «Leer la nota»

- [+ 43.7s] 💬 Persona: Leer la nota
- [+ 43.7s] 💬 JEF: Párrafos 1 a 2 de 10:
- [+ 43.7s] 🔊 «Párrafos 1 a 2 de 10:»
- [+ 43.7s] 💬 JEF: La investigación oficial sobre el apagón que dejó sin electricidad a casi 600.000 usuarios del Área Metropolitana de Buenos Aires apunta a la contaminación del gas utilizado por uno de los interruptores de alta tensión de Edenor. La empresa, sin embargo, todavía no convalida esa explicación y sostiene que continúa analizando las causas de la falla.
- [+ 43.7s] 🔊 «La investigación oficial sobre el apagón que dejó sin electricidad a casi 600.000 usuarios del Área Metropolitana de Buenos Aires apunta a la contaminación del gas utilizado por uno de los interruptores de alta tensión de Edenor. La empresa, sin embargo, todavía no convalida esa explicación y sostiene que continúa analizando las causas de la falla.»
- [+ 43.7s] 💬 JEF: Según pudo confirmar Clarín con fuentes de la Secretaría de Energía, el desperfecto se produjo en el interruptor L46 de la subestación Malaver, ubicada en el partido bonaerense de San Martín. El equipo contenía gas hexafluoruro de azufre (SF6), utilizado como aislante en instalaciones eléctricas de alta tensión, que se encontraba contaminado.
- [+ 43.7s] 🔊 «Según pudo confirmar Clarín con fuentes de la Secretaría de Energía, el desperfecto se produjo en el interruptor L46 de la subestación Malaver, ubicada en el partido bonaerense de San Martín. El equipo contenía gas hexafluoruro de azufre (SF6), utilizado como aislante en instalaciones eléctricas de alta tensión, que se encontraba contaminado.»  ⟶ DESCARTADO: lo cortó un pedido nuevo antes de que sonara
- [+ 43.7s] 🔘 Botones: [Seguir leyendo] · [Resumir la nota] · [Volver a la página anterior] · [Otra cosa]

Al terminar el paso (8 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-04.txt, captura en paso-04.jpg):
```
  1 [H] Asistente
  2 [H] Vos: clarín
  3 [txt] Buscando: clarín.
  4 [txt] Estás en los resultados de «clarín». Los 3 más probables:
  5 [H] Vos: Noticias. Últimas noticias de Argentina y el Mundo | Clarín — www.clarin.com
  6 [txt] Abriendo clarin.com.
  7 [txt] Estás en la portada de Clarin.com.
  8 [txt] Las primeras notas:
  9 [txt] El Gobierno apunta a un gas contaminado como la causa del corte de luz que afectó a casi dos millones de personas, La Secretaría de Energía informó que el problema se produjo en el interruptor L46 de…
 10 [txt] Renunció el secretario de Discapacidad en medio de la interna por los recortes del área en el Presupuesto 2027, Otra salida del Gobierno, Política, Renunció el secretario de Discapacidad en medio de…
 11 [txt] El Gobierno estima que por la visita del Papa se movilizarán 7 millones de personas y evalúa declarar asueto, Habrá tres misas masivas, Política, El Gobierno estima que por la visita del Papa se…
 12 [H] Vos: Abrir «El Gobierno apunta a un gas contaminado como la causa del corte de…»
 13 [txt] Abriendo «El Gobierno apunta a un gas contaminado como la causa del corte de…»
 14 [txt] Estás en una nota de Clarín sobre el apagón masivo que dejó sin luz a casi dos millones de personas. El Gobierno apunta a un gas contaminado como causa, mientras Edenor investiga el origen del desperfecto.
 15 [H] Vos: Leer la nota
 16 [txt] Párrafos 1 a 2 de 10:
 17 [txt] La investigación oficial sobre el apagón que dejó sin electricidad a casi 600.000 usuarios del Área Metropolitana de Buenos Aires apunta a la contaminación del gas utilizado por uno de los interruptores de alta tensión de Edenor. La empresa, sin embargo, todavía no convalida esa explicación y sostiene que continúa analizando las causas de la falla.
 18 [txt] Según pudo confirmar Clarín con fuentes de la Secretaría de Energía, el desperfecto se produjo en el interruptor L46 de la subestación Malaver, ubicada en el partido bonaerense de San Martín. El equipo contenía gas hexafluoruro de azufre (SF6), utilizado como aislante en instalaciones eléctricas de alta tensión, que se encontraba contaminado.
 19 [btn] Seguir leyendo  (Primera de 4 opciones.)
 20 [btn] Resumir la nota
 21 [btn] Volver a la página anterior
 22 [btn] Otra cosa
 23 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 24 [btn] Enviar
```

## Paso 5 — toca el botón 1: «Seguir leyendo»

- [+ 53.4s] 💬 Persona: Seguir leyendo
- [+ 53.4s] 💬 JEF: Párrafos 3 a 4 de 10:
- [+ 53.4s] 🔊 «Párrafos 3 a 4 de 10:»
- [+ 53.4s] 💬 JEF: “La falla se originó en un gas que llevan los interruptores. Se encontraba contaminado el gas SF6 del interruptor L46 y eso causó fallas en cadena en todo el sistema”, indicaron desde la Secretaría, que participa de la investigación a través del Ente Nacional Regulador del Gas y la Electricidad (Enrege).
- [+ 53.4s] 🔊 «“La falla se originó en un gas que llevan los interruptores. Se encontraba contaminado el gas SF6 del interruptor L46 y eso causó fallas en cadena en todo el sistema”, indicaron desde la Secretaría, que participa de la investigación a través del Ente Nacional Regulador del Gas y la Electricidad (Enrege).»
- [+ 53.4s] 💬 JEF: La versión de Edenor es, por el momento, más cautelosa. Desde la distribuidora se limitaron a señalar que “fue una falla en 220 kV en la subestación Malaver” y agregaron: “ Estamos investigando la causa”. La compañía no atribuyó oficialmente el episodio a la contaminación del SF6.
- [+ 53.4s] 🔊 «La versión de Edenor es, por el momento, más cautelosa. Desde la distribuidora se limitaron a señalar que “fue una falla en 220 kV en la subestación Malaver” y agregaron: “ Estamos investigando la causa”. La compañía no atribuyó oficialmente el episodio a la contaminación del SF6.»  ⟶ en cola: empieza a sonar a los +76.7s
- [+ 53.4s] 🔘 Botones: [Seguir leyendo] · [Resumir la nota] · [Volver a la página anterior] · [Otra cosa]

Al terminar el paso (9 s), lo que VoiceOver puede recorrer en la conversación (árbol completo en arbol-05.txt, captura en paso-05.jpg):
```
  1 [H] Asistente
  2 [H] Vos: clarín
  3 [txt] Buscando: clarín.
  4 [txt] Estás en los resultados de «clarín». Los 3 más probables:
  5 [H] Vos: Noticias. Últimas noticias de Argentina y el Mundo | Clarín — www.clarin.com
  6 [txt] Abriendo clarin.com.
  7 [txt] Estás en la portada de Clarin.com.
  8 [txt] Las primeras notas:
  9 [txt] El Gobierno apunta a un gas contaminado como la causa del corte de luz que afectó a casi dos millones de personas, La Secretaría de Energía informó que el problema se produjo en el interruptor L46 de…
 10 [txt] Renunció el secretario de Discapacidad en medio de la interna por los recortes del área en el Presupuesto 2027, Otra salida del Gobierno, Política, Renunció el secretario de Discapacidad en medio de…
 11 [txt] El Gobierno estima que por la visita del Papa se movilizarán 7 millones de personas y evalúa declarar asueto, Habrá tres misas masivas, Política, El Gobierno estima que por la visita del Papa se…
 12 [H] Vos: Abrir «El Gobierno apunta a un gas contaminado como la causa del corte de…»
 13 [txt] Abriendo «El Gobierno apunta a un gas contaminado como la causa del corte de…»
 14 [txt] Estás en una nota de Clarín sobre el apagón masivo que dejó sin luz a casi dos millones de personas. El Gobierno apunta a un gas contaminado como causa, mientras Edenor investiga el origen del desperfecto.
 15 [H] Vos: Leer la nota
 16 [txt] Párrafos 1 a 2 de 10:
 17 [txt] La investigación oficial sobre el apagón que dejó sin electricidad a casi 600.000 usuarios del Área Metropolitana de Buenos Aires apunta a la contaminación del gas utilizado por uno de los interruptores de alta tensión de Edenor. La empresa, sin embargo, todavía no convalida esa explicación y sostiene que continúa analizando las causas de la falla.
 18 [txt] Según pudo confirmar Clarín con fuentes de la Secretaría de Energía, el desperfecto se produjo en el interruptor L46 de la subestación Malaver, ubicada en el partido bonaerense de San Martín. El equipo contenía gas hexafluoruro de azufre (SF6), utilizado como aislante en instalaciones eléctricas de alta tensión, que se encontraba contaminado.
 19 [H] Vos: Seguir leyendo
 20 [txt] Párrafos 3 a 4 de 10:
 21 [txt] “La falla se originó en un gas que llevan los interruptores. Se encontraba contaminado el gas SF6 del interruptor L46 y eso causó fallas en cadena en todo el sistema”, indicaron desde la Secretaría, que participa de la investigación a través del Ente Nacional Regulador del Gas y la Electricidad (Enrege).
 22 [txt] La versión de Edenor es, por el momento, más cautelosa. Desde la distribuidora se limitaron a señalar que “fue una falla en 220 kV en la subestación Malaver” y agregaron: “ Estamos investigando la causa”. La compañía no atribuyó oficialmente el episodio a la contaminación del SF6.
 23 [btn] Seguir leyendo  (Primera de 4 opciones.)
 24 [btn] Resumir la nota
 25 [btn] Volver a la página anterior
 26 [btn] Otra cosa
 27 [campo] Pedido  = ¿Qué querés hacer?  (Un sitio, algo para buscar o una pregunta. También se puede dictar con el teclado.)
 28 [btn] Enviar
```
