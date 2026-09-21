export const meta = {
  name: 'jueces-jef',
  description: 'Jueces ciegos, baja visión y verificadores evalúan una ronda de escenarios de JEF',
  whenToUse: 'Después de correr Scripts/probar-escenarios.py, para evaluar la ronda',
  phases: [
    { title: 'Juzgar', detail: '4 personas + 2 verificadores leen las transcripciones' },
    { title: 'Sintetizar', detail: 'agrupar y priorizar los problemas' },
    { title: 'Verificar', detail: 'escépticos: ¿pasa de verdad y es de la app?' },
  ],
}

// Los jueces de una ronda de pruebas de JEF, como workflow de Claude Code.
//
// Después de correr Scripts/probar-escenarios.py, se lanza con la herramienta
// Workflow: scriptPath = este archivo, args = {"dir": "<ruta absoluta de la
// ronda>", "escenarios": ["<id>", ...]}. Tres personas ciegas simuladas,
// una con baja visión, dos verificadores que ven, una síntesis y escépticos
// que confirman cada problema. Lo que devuelve va a jueces.json de la ronda, y
// Scripts/veredicto.py arma veredicto.md.

const DIR = args.dir
const IDS = args.escenarios

const CONTEXTO = `JEF es una app para iPhone pensada para personas ciegas o con baja visión: un asistente para usar la web sin verla. Arriba se ve la página web tal cual; abajo hay una conversación. La persona escribe o dicta pedidos ("llevame a la nación", "¿a cuánto está el dólar?") y el asistente busca, navega, lee, resume o contesta. Toda respuesta debería terminar con botones de próximos pasos y "Otra cosa" (que deja escribir).

Cómo se hicieron las pruebas: un script corrió cada escenario en el simulador. En cada paso escribió un pedido o tocó un botón ofrecido. "toca el botón 1" significa que el script tocó MECÁNICAMENTE la primera opción, no que la persona la eligiera: juzgá si esa primera opción era una buena primera opción, no la elección. Si el script no pudo hacer un paso (⚠️), es porque no había la opción esperada: eso sí es un hecho del producto. Las páginas son reales y del día.

El simulador no corre VoiceOver: lo que se habría escuchado sale de un registro de la app (🔊). Un anuncio nuevo corta al que se está diciendo; los que quedaron cortados están marcados CORTADO (estimación a 14 caracteres por segundo). Además, cuando el asistente termina de responder, el cursor de VoiceOver se lleva a la última línea escrita y VoiceOver la lee. Con gestos, la persona puede recorrer todo lo que figura en el bloque "lo que VoiceOver puede recorrer" de cada paso.`

const RUTAS = IDS.map(id => `- ${DIR}/${id}/transcripcion.md`).join('\n')

const PERSONAS = [
  { nombre: 'Marta', ve: false, desc: '52 años, ciega desde los 30 por retinosis pigmentaria. Usa iPhone con VoiceOver hace veinte años, con la voz muy rápida. Navega con el rotor, sabe lo que quiere y odia esperar, las vueltas y que le hablen de más. Desconfía de las apps "para ciegos" que la tratan como si no supiera usar un teléfono.' },
  { nombre: 'Roberto', ve: false, desc: '72 años, jubilado, perdió la vista hace tres años por glaucoma. Usa VoiceOver desde hace poco y sólo sabe lo básico: deslizar para pasar de un elemento a otro y tocar dos veces. Se pierde fácil, necesita que le digan dónde está y qué puede hacer, escribir le cuesta mucho, y cuando algo sale mal no sabe cómo volver.' },
  { nombre: 'Lucía', ve: false, desc: '29 años, ciega de nacimiento, desarrolladora de software. Usa lectores de pantalla desde chica. Exige precisión: detecta al instante cuando algo suena inventado, técnico o contradictorio, y valora su autonomía: que le den opciones, no que decidan por ella. Le importa la privacidad.' },
  { nombre: 'Ana', ve: true, desc: '64 años, baja visión por degeneración macular: ve de cerca, con esfuerzo, y usa el texto grande. No usa VoiceOver: lee la pantalla acercándose, y le cuesta encontrar lo que no está donde espera o queda escondido.' },
]

const PERSONA_SCHEMA = {
  type: 'object',
  properties: {
    persona: { type: 'string' },
    escenarios: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          logro: { type: 'string', enum: ['sí', 'a medias', 'no'] },
          orientacion: { type: 'integer', minimum: 1, maximum: 5 },
          comprension: { type: 'integer', minimum: 1, maximum: 5 },
          confianza: { type: 'integer', minimum: 1, maximum: 5 },
          control: { type: 'integer', minimum: 1, maximum: 5 },
          ritmo: { type: 'integer', minimum: 1, maximum: 5 },
          momentos: {
            type: 'array',
            items: {
              type: 'object',
              properties: {
                paso: { type: 'integer' },
                cita: { type: 'string' },
                problema: { type: 'string' },
                gravedad: { type: 'string', enum: ['bloqueante', 'grave', 'menor'] },
                sugerencia: { type: 'string' },
              },
              required: ['paso', 'cita', 'problema', 'gravedad', 'sugerencia'],
            },
          },
          loQueSirvio: { type: 'array', items: { type: 'string' } },
          resumen: { type: 'string' },
        },
        required: ['id', 'logro', 'orientacion', 'comprension', 'confianza', 'control', 'ritmo', 'momentos', 'loQueSirvio', 'resumen'],
      },
    },
    generales: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          problema: { type: 'string' },
          gravedad: { type: 'string', enum: ['bloqueante', 'grave', 'menor'] },
          escenarios: { type: 'array', items: { type: 'string' } },
          sugerencia: { type: 'string' },
        },
        required: ['problema', 'gravedad', 'escenarios', 'sugerencia'],
      },
    },
  },
  required: ['persona', 'escenarios', 'generales'],
}

const VERIF_SCHEMA = {
  type: 'object',
  properties: {
    escenarios: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          hallazgos: {
            type: 'array',
            items: {
              type: 'object',
              properties: {
                paso: { type: 'integer' },
                tipo: { type: 'string', enum: ['inventado', 'dato-incorrecto', 'pagina-equivocada', 'boton-enganoso', 'tecnicismo', 'idioma', 'no-se-ve', 'omision', 'otro'] },
                cita: { type: 'string' },
                evidencia: { type: 'string' },
                gravedad: { type: 'string', enum: ['bloqueante', 'grave', 'menor'] },
              },
              required: ['paso', 'tipo', 'cita', 'evidencia', 'gravedad'],
            },
          },
          correcto: { type: 'array', items: { type: 'string' } },
        },
        required: ['id', 'hallazgos', 'correcto'],
      },
    },
  },
  required: ['escenarios'],
}

const SINTESIS_SCHEMA = {
  type: 'object',
  properties: {
    resumen: { type: 'string' },
    problemas: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          titulo: { type: 'string' },
          gravedad: { type: 'string', enum: ['bloqueante', 'grave', 'menor'] },
          jueces: { type: 'array', items: { type: 'string' } },
          escenarios: { type: 'array', items: { type: 'string' } },
          evidencia: { type: 'array', items: { type: 'string' } },
          causaProbable: { type: 'string' },
          propuesta: { type: 'string' },
        },
        required: ['id', 'titulo', 'gravedad', 'jueces', 'escenarios', 'evidencia', 'causaProbable', 'propuesta'],
      },
    },
    loQueFunciona: { type: 'array', items: { type: 'string' } },
    tablero: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          escenario: { type: 'string' },
          logros: { type: 'string' },
          promedio: { type: 'number' },
          comentario: { type: 'string' },
        },
        required: ['escenario', 'logros', 'promedio', 'comentario'],
      },
    },
  },
  required: ['resumen', 'problemas', 'loQueFunciona', 'tablero'],
}

const VEREDICTO_SCHEMA = {
  type: 'object',
  properties: {
    veredictos: {
      type: 'array',
      items: {
        type: 'object',
        properties: {
          id: { type: 'string' },
          real: { type: 'boolean' },
          delArnes: { type: 'boolean' },
          motivo: { type: 'string' },
        },
        required: ['id', 'real', 'delArnes', 'motivo'],
      },
    },
  },
  required: ['veredictos'],
}

function promptPersona(p) {
  const acceso = p.ve
    ? `Vos sí ves, con esfuerzo: además de cada transcripcion.md mirá las capturas paso-NN.jpg de cada escenario (abrilas con Read). Juzgá sobre todo lo que se ve: si encontrás la respuesta y los botones en la pantalla, si el texto es legible, si hay cosas escondidas o fuera de lugar.`
    : `No ves la pantalla. Leé SÓLO los archivos transcripcion.md. NO abras las capturas (.jpg), ni paginas/, ni arbol-*.txt: vos sólo sabés lo que escuchaste y lo que podés recorrer con VoiceOver. Tené en cuenta los anuncios CORTADOS: esos no los escuchaste enteros.`
  return `${CONTEXTO}

Sos ${p.nombre}: ${p.desc}

Vas a evaluar ${IDS.length} sesiones de JEF como si las hubieras vivido vos. Cada transcripción dice quién sos en ese escenario y qué querías lograr; ponete en ese lugar, con tu forma de ser.
${acceso}

Transcripciones:
${RUTAS}

Para cada escenario: ¿conseguiste lo que querías? Puntuá de 1 a 5: orientación (en cada momento sabés dónde estás y qué pasó), comprensión (se entiende, sin tecnicismos), confianza (le creés; nada suena inventado ni contradictorio), control (sabés qué podés hacer ahora; los botones son los que necesitás), ritmo (ni de más ni de menos: no te hace esperar ni te marea). Anotá los momentos concretos que te molestaron, con la cita textual, el paso, y cuán grave es para vos (bloqueante: no pudiste seguir; grave: te confundió o te hizo perder tiempo; menor: molesto). Anotá también lo que te sirvió. Escribí como ${p.nombre}, en primera persona, pero concreto: cada problema tiene que poder arreglarse. Al final, los problemas generales que se repiten entre escenarios.`
}

function promptVerificador(ids) {
  return `${CONTEXTO}

Sos un verificador que VE. Tu trabajo: comprobar que lo que JEF le dijo a una persona ciega sea cierto, y que cada acción haya hecho lo que dijo.

Para cada escenario de tu lista, en ${DIR}/<id>/:
- Leé transcripcion.md.
- Para cada línea "JEF:" que afirme algo sobre una página (un dato, un titular, un número, "estás en…", un resumen), comparala con el texto que el asistente tenía delante: paginas/NN.txt, donde NN es el número que figura en la línea 📄 de esa página en la transcripción.
- Mirá las capturas paso-NN.jpg con Read: muestran la página real (arriba) y la conversación (abajo). Revisá que lo dicho coincida con lo que se ve, y que la conversación sea usable a la vista (por ejemplo: botones que existen pero no se ven).
- Revisá que cada botón ofrecido lleve a lo que dice (mirá el paso siguiente cuando el script lo tocó), que no se filtren tecnicismos ni nombres internos, y que todo esté en castellano.
No juzgues la calidad de la web en sí. Reportá sólo hallazgos con evidencia: la cita de JEF y lo que dice la página o se ve en la captura. Anotá también lo que verificaste como correcto.

Escenarios: ${ids.join(', ')}`
}

phase('Juzgar')
const mitad = Math.ceil(IDS.length / 2)
const tareas = [
  ...PERSONAS.map(p => () => agent(promptPersona(p), { label: `juez:${p.nombre}`, phase: 'Juzgar', schema: PERSONA_SCHEMA })),
  () => agent(promptVerificador(IDS.slice(0, mitad)), { label: 'verificador:A', phase: 'Juzgar', schema: VERIF_SCHEMA }),
  () => agent(promptVerificador(IDS.slice(mitad)), { label: 'verificador:B', phase: 'Juzgar', schema: VERIF_SCHEMA }),
]
// Barrera a propósito: la síntesis tiene que ver TODOS los juicios juntos
// para agrupar un mismo problema que marcaron varios jueces.
const juicios = await parallel(tareas)
const personas = juicios.slice(0, PERSONAS.length).filter(Boolean)
const verificadores = juicios.slice(PERSONAS.length).filter(Boolean)
log(`${personas.length} jueces y ${verificadores.length} verificadores respondieron`)

phase('Sintetizar')
const sintesis = await agent(`${CONTEXTO}

Cuatro jueces (tres personas ciegas y una con baja visión) y dos verificadores videntes evaluaron ${IDS.length} escenarios de JEF. Sus juicios, en JSON:

${JSON.stringify({ personas, verificadores })}

Tu trabajo: juntar lo que dicen en una lista de problemas del PRODUCTO, sin duplicados (el mismo problema marcado por varios jueces o en varios escenarios es UNO, con todos sus jueces y escenarios), ordenada por importancia: primero lo que impide lograr el objetivo, después lo que confunde o hace perder tiempo, al final lo molesto. Para cada problema: evidencia (citas textuales de las transcripciones), la causa probable y una propuesta concreta. Para la causa podés mirar el código en /Users/daniel/Developer/JEF- BROWSER/Sources (sobre todo Intelligence/Assistant.swift, Intelligence/Answerer.swift, UI/AssistantPanel.swift, Extraction/extract.js) y las transcripciones en ${DIR}; no modifiques nada. Descartá lo que sea sólo del script de prueba. Sumá lo que funciona bien (para no romperlo) y un tablero por escenario: los logros de cada juez ("Marta sí, Roberto no, …") y el promedio de sus cinco puntajes.`, { label: 'sintesis', phase: 'Sintetizar', schema: SINTESIS_SCHEMA })

phase('Verificar')
const problemas = (sintesis && sintesis.problemas) || []
const tandas = []
for (let i = 0; i < problemas.length; i += 6) tandas.push(problemas.slice(i, i + 6))
const veredictos = (await parallel(tandas.map((tanda, n) => () => agent(`${CONTEXTO}

Sos un escéptico. Estos problemas salieron de jueces que evaluaron las transcripciones en ${DIR}. Para cada uno, buscá la evidencia vos mismo en las transcripciones (y en paginas/ o en las capturas si hace falta) y decidí:
- real: ¿pasa de verdad, como está descripto? Si no encontrás la evidencia, real=false.
- delArnes: ¿es culpa del script de prueba y no de la app? (por ejemplo: que el script tocó mecánicamente la primera opción, o una estimación de corte de voz que no se sostiene).
Explicá el motivo en una o dos frases, con la cita que lo prueba o lo refuta.

Problemas:
${JSON.stringify(tanda)}`, { label: `esceptico:${n + 1}`, phase: 'Verificar', schema: VEREDICTO_SCHEMA })))).filter(Boolean).flatMap(v => v.veredictos)

return { personas, verificadores, sintesis, veredictos }
