# La forma de una página

Este documento define **cómo suena una página en JEF**, antes de cualquier
heurística. Hasta ahora el orden emergía de qué reglas de extracción
matchearon; el resultado era distinto en cada sitio y lo que no encajaba en
ninguna regla quedaba flotando al final. Acá se decide primero la forma, y el
código y Jev se acomodan a ella.

## El problema que resuelve

VoiceOver lee en línea recta. No hay vistazo, no hay periferia, no hay saltar
con la mirada. Entonces **el orden es la interfaz**: lo que está en la parada
tres existe, y lo que está en la parada treinta, para la mayoría de la gente,
no. Reservar un vuelo no puede costar treinta paradas de menú antes de llegar
al botón.

## El principio que limita a todos los demás

**No transformamos el contenido. Lo agrupamos.**

La página se carga tal como es. Nosotros no reescribimos, no resumimos, no
descartamos y no traducimos lo que el sitio dice. Lo único que hacemos es
ponerle un orden y unos nombres a los grupos, porque el orden es lo que la
vista da gratis y una lectura lineal no.

La línea es precisa:

- **Agregar contexto que la página ya tenía en forma visual, sí.** Emparejar
  un valor con el nombre de su columna, decir "1 de 7", poner título a un
  grupo. Esa información estaba ahí: la geometría la daba y nosotros la
  decimos.
- **Reescribir o descartar, no.** Ni una etiqueta, ni un precio, ni un
  párrafo.

Las palabras que ponemos nosotros son siempre **nombres de cajas**, nunca
reemplazos de lo que hay adentro. "Consultar mis cuentas" nombra el grupo;
adentro el link sigue diciendo "Posición consolidada", que es como lo llama
el banco y como la persona va a tener que pedirlo si llama por teléfono o si
un día abre la página original.

Esto tiene una consecuencia concreta sobre la arquitectura actual:
**Readability no puede seguir siendo el portero de qué es contenido.** Hoy lo
que queda fuera de "el artículo" puede desaparecer, y de ahí viene el texto
que aparece suelto al final. Todo lo que está en el cuerpo tiene que aterrizar
en algún tramo: contenido, una opción, o el cajón de Información.

## El orden es el de la página

Durante un tiempo reordenamos: lo que Jev creía que era la intención iba
arriba, las acciones se repartían en categorías nuestras ("Comprar o
reservar", "Consultar un dato") y cada tipo de página tenía su propio layout.
El resultado fue peor que la página original. El login de un diario leía todo
el texto, después todos los botones y después el formulario, con "ó ingresá
con tu email" sonando antes que los botones de los que es alternativa; los
botones de ingreso terminaban en "Otras opciones" junto a "Volver"; la portada
mostraba 37 de sus 133 titulares.

La causa era una sola: el extractor desarmaba la página en inventarios
separados —texto, acciones, formularios, listados— y tiraba el orden entre
ellos, que era lo único que la página ya traía resuelto. Todo lo demás era
intentar reinventarlo adivinando.

Entonces: **el extractor recorre la página una sola vez, de arriba abajo, y
entrega cada cosa en el lugar donde la página la muestra.** No reordenamos y
no categorizamos. El orden que vale es el que se *ve*: cuando el sitio
reordena con CSS (`order`, `column-reverse`), se lee como se ve y no como
está escrito, porque eso es geometría que la página ya tenía.

Con ese piso, no entender algo deja de significar perderlo: significa
mostrarlo donde estaba. Lo peor que puede pasar es que una página quede igual
que la original.

Sobre ese orden hacemos sólo lo que la vista le da gratis a quien ve:

- **Vecinas que son una lista se leen como una lista.** Opciones seguidas que
  comparten contenedor van juntas, en una tarjeta, una fila cada una. Las que
  se tocan sin compartirlo son vecinas, no una lista.
- **Una lista larga se reconoce sin leerla entera.** Pasado el presupuesto, es
  una caja con nombre y cantidad, que abre una pantalla con la lista plana.
- **El pie se saltea.** Largo, es una parada: "Resto del sitio".
- **Lo que no dice nada no se mira.** Ver "Ruido", abajo.

### Cajas, no desplegables

Lo que se pliega **abre una pantalla; nunca se despliega en el lugar.** Un
desplegable obliga a recorrer una sección entera para llegar a la siguiente;
una caja es una parada, y la siguiente caja es la parada siguiente.

El nombre de una caja es el que la página le puso —el encabezado que tenía
arriba, el título del listado, el control que se tocó para abrirla— y, si no
le puso ninguno, lo que hay adentro ("Salud, Educación, Cultura y 5 más").
Nunca una categoría nuestra.

La portada de un diario es el caso grande: ciento treinta titulares no son una
pantalla. Es una caja —**Portada, 161 titulares**— donde la portada empieza, y
adentro las secciones que el diario ya tenía ("Análisis", "Actualidad",
"Deportes"), cada una en su caja, en el orden del diario. El link a la página
en la que ya se está ("Inicio") abre lo mismo, en vez de recargar.

### Ruido

Hay paradas que no dicen nada: un emoji suelto, una imagen que se llama como
su archivo (`prod-lanacion`), un botón o un link que el sitio nunca nombró.
**No se descartan: salen del recorrido y van juntas a una caja al final,**
"Símbolos y elementos sin nombre". El botón sin nombre puede ser el chat o el
cierre de un modal; tiene que seguir siendo alcanzable.

Lo único que sí desaparece es la tipografía: la barra entre dos links, la
viñeta suelta. Es lo mismo que un `<hr>`: geometría, no contenido.

## Tres principios más

**Nada se pierde.** Todo lo que la página dice tiene que estar en algún lugar
nombrado. Lo que no entra en ninguna categoría no se descarta ni se deja
flotando: va a un cajón que se llama por lo que tiene adentro. El costo de
esconder algo que importaba es mucho más alto que el de una parada de más.

**Hay un presupuesto de paradas.** No hay una cifra oficial; hay dos cosas
que sí se saben. Una lista hablada no se puede releer de un vistazo: los
menús telefónicos se diseñan con cuatro o cinco opciones, y siete es el techo
de lo que se retiene. Y cada parada cuesta dos o tres segundos entre el gesto
y la escucha: ocho paradas son veinte segundos, veinticinco un minuto, y las
359 de la portada de un diario, un cuarto de hora. De ahí los números, que
viven en un solo lugar del código (`StopBudget`) para calibrarlos con uso
real:

- **8** paradas como máximo entre el título y el contenido. No es un
  objetivo, es un techo: si algo no entra, se contrae.
- **7** opciones seguidas se escuchan enteras. Más, es una caja.
- **25** paradas por pantalla. Una pantalla que lo pasa y tiene secciones
  propias las ofrece como cajas.
- Una lista homogénea —titulares, resultados— puede ser más larga: cada
  parada dice "3 de 12" y son todas la misma clase de cosa.

Las reglas miran grupos, no páginas: no hay un tamaño de página a partir del
cual "no se toca". Una página chica sale casi tal cual porque ninguna regla
dispara, no porque un umbral lo diga — y aun así se le saca el ruido.

**Los nombres son los de una persona, no los nuestros.** "Pie de página" no es
algo que alguien quiera visitar. Tampoco "información poco relevante": nadie
quiere que le digan que lo que está por escuchar no vale la pena, y además
puede no ser cierto para esa persona. Un cajón se llama por lo que contiene.

## La forma

Un solo layout, para toda página.

### 1. Dónde estoy — siempre, dos paradas

El sitio primero y la página después, sin el separador ni los sufijos:
`Inicio | Braille Perú` se dice **"Braille Perú. Inicio."**. Y una línea de
qué es esto, tomada de la descripción del sitio o, si no hay, de la primera
frase del contenido.

> Braille Perú. Inicio.
> Señalética braille y accesibilidad para instituciones.

Es el ancla: si entraste mal, esto es lo único que te lo dice. Nada va antes,
ni siquiera lo que la app tenga para contar sobre sí misma. Lo único que se le
adelanta al resto es lo que tapa la página —un aviso de cookies, un muro— y
lo que el último toque hizo aparecer, con el nombre de lo que se tocó
("Secciones, 32 opciones").

### 2. La página, en su orden

Lo que la página dice, lo que deja hacer y lo que lista, cada cosa donde la
página la muestra, con las reglas de arriba: listas cortas abiertas, largas
en cajas, el formulario donde estaba y con los botones que tenía al lado.

En una página que es una tarea — un checkout, un login — el contenido es el
formulario, y va con su estado por delante: qué campo apareció, cuál falta,
por qué no avanzó.

### 3. Lo que se aparta — al final, una parada cada cosa

- **Resto del sitio** — el pie: legales, redes, el mapa del sitio.
- **Símbolos y elementos sin nombre** — el ruido.

Nada se descartó: está ahí y se abre si se quiere.

### Pendiente: de un vistazo

Los datos que una persona que ve absorbe sin buscarlos — el dólar en un
diario, el clima, el carrito — hoy quedan donde la página los puso, una
parada cada uno. La idea sigue en pie: una sola parada corta, "Dólar oficial
1.534. Dólar blue 1.720.", y nunca más de cuatro datos.

## Quién decide qué

**El código decide la forma, siempre.** Todo lo de arriba sale del DOM: el
orden, qué es una lista, cuándo se pliega, cómo se llama cada caja, qué es
una portada (la página es sobre todo titulares: links que además son
encabezado). Nada de eso se le pregunta a nadie, porque preguntarlo agrega
variabilidad y una espera: la misma página no puede tener una forma si la red
contesta y otra si no.

**Jev no decide el layout.** Una página que se lee en su orden no lo llama.
Lo que le queda es lo que el DOM no puede decir — ponerle nombre, eligiendo
entre candidatos que ya están en la página, a un grupo que el sitio dejó sin
nombre — y siempre como mejora: si falla, la página es la misma.

Medido, y por eso: los treinta y cuatro botones de un calendario de precios
son un solo control para una persona, y juzgados de a uno se repartieron
entre tres categorías distintas y en la corrida siguiente entre otras. La
etiqueta "10 de octubre, 112.935 ARS" no contiene la información de que hay
treinta y tres hermanas iguales. El DOM sí.

**Todavía en el layout anterior:** los artículos (su texto sale del recorte
de Readability, que no tiene lugar en el recorrido) y las páginas de tarea
grandes — el buscador de una aerolínea, la home de un banco. Son lo que
sigue.

## Cada arreglo es una regla sobre el DOM

La web real está sucia, y cada sitio nuevo muestra una mugre nueva: un
`<div role="button">` que envuelve un menú entero, un `<a href="#">` que en
realidad es un botón, un link vacío estirado sobre una tarjeta, un menú que
abre con una transición que un WebView fuera de pantalla nunca avanza. No se
termina, pero se achica: son clases de problema, no sitios.

La condición es que cada arreglo sea **una regla sobre el DOM y no sobre el
sitio**, escrita una vez en `extract.js`, y nunca un modo nuevo del layout.
Las reglas se suman; los modos se multiplican.

Y que haya red: `./Scripts/read-page.js --all` corre el extractor real contra
los sitios de `Tests/sites.txt` y dice, por cada uno, cuántas paradas tenía,
cuántas quedaron y cuántos titulares de la página original llegaron. Antes de
cada cambio al extractor.

## Cuándo no intervenir

Reinterpretar una página que ya está bien hecha sólo puede restar: perder
algo, ordenarlo peor, o llamarlo distinto de como lo llama el sitio. Google
con VoiceOver funciona; nuestra versión de Google fue de las peores pantallas
de las pruebas.

Así que hay un paso previo a todo lo anterior: **medir si hace falta**. No es
una pregunta para Jev, porque la respuesta está en el DOM y se cuenta:

- ¿Hay landmarks y encabezados reales, o un solo `h1` y cuarenta `div`?
- ¿Todos los controles tienen nombre accesible? ¿Los campos, su `label`?
- ¿Las imágenes con contenido tienen `alt`?
- ¿Cuántas paradas tiene para el contenido que ofrece?
- Y la comparación que sólo nosotros podemos hacer: **cuántas paradas
  ahorraríamos**. Si son pocas, no hay nada que ganar.

Cuando la página pasa el examen, se muestra tal cual, **y se dice**:

> Esta página ya está bien hecha. La estás viendo tal cual.
> Tocá dos veces para reinterpretarla.

Nunca en silencio, y siempre reversible en un toque. La decisión de no
intervenir es una decisión, y quien navega tiene derecho a saberla y a
cambiarla.

## Lo que este documento no propone

No proponemos un catálogo de rubros, ni de tipos de página. "E-commerce",
"banco", "diario" son etiquetas de industria, y lo que rompe no es la
industria: la página de transferencia de un banco y el checkout de una
aerolínea son la misma forma, y la home de un diario y una categoría de
tienda también. Probamos con cinco tipos y un vocabulario de opciones para
cada uno; cada tipo terminó siendo un layout distinto, y entre todos nadie
podía predecir cómo iba a salir una página.

No proponemos esconder para acortar. El número de paradas baja porque las
cosas se agrupan y se nombran, no porque se descarten. Cada vez que la cuenta
baje, tiene que poder decirse dónde quedó lo que ya no está.
