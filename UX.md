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

## Tres principios

**Nada se pierde.** Todo lo que la página dice tiene que estar en algún lugar
nombrado. Lo que no entra en ninguna categoría no se descarta ni se deja
flotando: va a un cajón que se llama por lo que tiene adentro. El costo de
esconder algo que importaba es mucho más alto que el de una parada de más.

**Hay un presupuesto de paradas.** Entre el título y el contenido no puede
haber más de ocho paradas. No es un objetivo, es un techo: si algo no entra,
se contrae. Así "treinta elementos antes de reservar" deja de ser posible
aunque una heurística se equivoque.

**Los nombres son los de una persona, no los nuestros.** "Pie de página" no es
algo que alguien quiera visitar. Tampoco "información poco relevante": nadie
quiere que le digan que lo que está por escuchar no vale la pena, y además
puede no ser cierto para esa persona. Un cajón se llama por lo que contiene.

## La forma

Cinco tramos, en este orden, en toda página. Los tramos pueden estar vacíos;
el orden no cambia.

### 1. Dónde estoy — siempre, dos paradas

El sitio primero y la página después, sin el separador ni los sufijos:
`Inicio | Braille Perú` se dice **"Braille Perú. Inicio."**. Y una línea de
qué es esto, tomada de la descripción del sitio o, si no hay, de la primera
frase del contenido.

> Braille Perú. Inicio.
> Señalética braille y accesibilidad para instituciones.

Es el ancla: si entraste mal, esto es lo único que te lo dice. Nada va antes,
ni siquiera lo que la app tenga para contar sobre sí misma.

### 2. De un vistazo — sólo si los hay, máximo cuatro

Los datos que una persona que ve absorbe sin buscarlos: el dólar en un diario,
el clima, el carrito, las notificaciones sin leer, el estado de un vuelo.

Van acá por una razón precisa: **es lo que la vista da gratis**. No son
contenido ni son acciones; son cifras al paso. Por eso el tramo es corto y
sólo admite datos breves — en el momento en que algo de acá ocupa dos
renglones, no era un dato al paso.

> Dólar oficial 1.534. Dólar blue 1.720.

### 3. Qué querés hacer — las opciones, con las palabras del sitio

De cuatro a seis, nombradas con verbo, abiertas. Lo que no entra va a "más
opciones", contraído.

El diseño es siempre el mismo — cajas por intención — pero **cada tipo de
página trae su propio vocabulario, en su propio orden**. Un diario y un
marketplace no comparten opciones: uno ofrece "Leer los titulares", el otro
"Buscar un producto". Nombrar a los dos "Consultar un dato" es lo que hace
que la app suene a sistema y no a sitio.

| Tipo de página | Las opciones, en orden |
|---|---|
| **Puerta de entrada** (landing, home institucional) | Qué hacemos · Productos y servicios · Contacto · Sobre la empresa · Ingresar |
| **Banco o trámite** | Ingresar · Consultar mis cuentas · Operar · Ayuda · Quiénes somos |
| **Diario o portal** | Leer los titulares · Noticias por sección · Buscar una noticia · Mi suscripción |
| **Tienda o catálogo** | Buscar un producto · Ver categorías · Ofertas · Mis compras · Mi cuenta |
| **Artículo o referencia** | *(vacío: no hay tarea, el contenido es el punto)* |

El tramo puede estar vacío. En una nota de Wikipedia no hay nada que hacer, y
forzar un "¿Qué querés hacer?" ahí es lo que hace que la página suene rara.

Cada vocabulario cierra con un cajón propio para lo que no encaja en ninguna
de sus opciones, para que ninguna acción quede sin lugar.

### 4. El contenido — lo que la página es

El texto, el listado, la tabla, el formulario. Completo, en orden de lectura,
con su detalle. Este tramo no se resume ni se recorta: es a lo que vino la
persona.

En una página que es una tarea — un checkout, un login — el contenido es el
formulario, y va con su estado por delante: qué campo apareció, cuál falta,
por qué no avanzó.

### 5. Información — el cajón, en dos partes

Todo lo que no entró arriba, en dos grupos contraídos, en este orden:

- **Puede interesarte** — promociones, avisos, secciones destacadas, lo que la
  página puso a la vista aunque no sea su tema.
- **Resto del sitio** — menú, pie, legales, redes, "sobre la empresa" cuando
  no es el tema de la página.

Dos paradas, no cincuenta. Nada se descartó: está ahí y se abre si se quiere.

## Quién decide qué

**El código decide cuando la estructura no deja dudas.** Un formulario de
veinte campos con su botón es una tarea. Una tabla que ocupa la mayor parte de
la página es un dato para consultar. Un cluster de botones hermanos idénticos
es una sola decisión. Nada de esto se le pregunta a nadie: el DOM ya lo dice, y
preguntarlo sólo agrega ruido y variabilidad.

**Jev decide tres cosas, y las tres son preguntas tipadas de pocas opciones**,
que es donde demostró ser confiable:

1. **Qué tipo de página es esta** — una `choice` entre los cinco tipos de la
   tabla. Elige el vocabulario y el orden del tramo 3. Si la confianza es
   baja, cae en "puerta de entrada", que es la más conservadora porque
   muestra un poco de todo.
2. **A qué opción pertenece cada acción** — una `choice` entre las opciones
   de *ese* vocabulario, no entre categorías globales.
3. **Dónde va cada cosa suelta** — una `choice` entre *dato al paso*, *puede
   interesarte* y *resto del sitio*, para cada bloque que no encontró lugar.

Lo que Jev **no** hace es clasificar acción por acción. Medido: los treinta y
cuatro botones de un calendario de precios son un solo control para una
persona, y juzgados de a uno se repartieron entre tres categorías distintas y
en la corrida siguiente entre otras. La etiqueta "10 de octubre, 112.935 ARS"
no contiene la información de que hay treinta y tres hermanas iguales. El DOM
sí.

**El tipo se pega al flujo.** Una vez adentro de un trámite, todas las
pantallas de ese trámite son del mismo tipo. No se vuelve a decidir en cada
paso, porque eso reordenaría la página en medio de la tarea.

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

No proponemos un catálogo de rubros. "E-commerce", "banco", "diario" son
etiquetas de industria, y lo que rompe no es la industria: la página de
transferencia de un banco y el checkout de una aerolínea son la misma forma, y
la home de un diario y una categoría de tienda también. Los cinco tipos de la
tabla son formas, no rubros.

No proponemos esconder para acortar. El número de paradas baja porque las
cosas se agrupan y se nombran, no porque se descarten. Cada vez que la cuenta
baje, tiene que poder decirse dónde quedó lo que ya no está.
