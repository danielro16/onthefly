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

### 3. Qué querés hacer — las opciones, rankeadas

De cuatro a seis, nombradas con verbo, abiertas. Lo que no entra va a "más
opciones", contraído.

El ranking **depende del tipo de página**, y eso es todo lo que el tipo de
página decide. No hay cinco diseños distintos: hay un orden distinto de las
mismas categorías.

| Tipo de página | Qué va primero | Qué va último |
|---|---|---|
| Puerta de entrada (landing, home institucional) | Qué hace esta empresa, sus servicios | Ingresar, legales |
| Banco, cuenta, trámite | Ingresar, operar | Quiénes somos |
| Diario, portal de noticias | Leer los titulares | Suscribirse, institucional |
| Tienda, catálogo | Buscar, ver productos | Sobre la tienda |
| Artículo, entrada de referencia | *(vacío: no hay tarea, el contenido es el punto)* | — |

El tramo puede estar vacío. En una nota de Wikipedia no hay nada que hacer, y
forzar un "¿Qué querés hacer?" ahí es lo que hace que la página suene rara.

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

**Jev decide dos cosas, y las dos son preguntas tipadas de pocas opciones**,
que es donde demostró ser confiable:

1. **Qué tipo de página es esta** — una `choice` entre los cinco tipos de la
   tabla. Decide el ranking del tramo 3, nada más. Si la confianza es baja,
   cae en "puerta de entrada", que es la más conservadora porque muestra un
   poco de todo.
2. **Dónde va cada cosa suelta** — una `choice` entre *dato al paso*, *puede
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

## Lo que este documento no propone

No proponemos un catálogo de rubros. "E-commerce", "banco", "diario" son
etiquetas de industria, y lo que rompe no es la industria: la página de
transferencia de un banco y el checkout de una aerolínea son la misma forma, y
la home de un diario y una categoría de tienda también. Los cinco tipos de la
tabla son formas, no rubros.

No proponemos esconder para acortar. El número de paradas baja porque las
cosas se agrupan y se nombran, no porque se descarten. Cada vez que la cuenta
baje, tiene que poder decirse dónde quedó lo que ya no está.
