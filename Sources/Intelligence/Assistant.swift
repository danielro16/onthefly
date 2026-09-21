import Foundation
import UIKit

/// El asistente: la persona dice a dónde quiere ir y JEF la lleva.
///
/// La web se carga tal como es. No se reordena, no se agrupa, no se dibuja de
/// nuevo: lo único que se agrega es esta conversación. Recorrer una página con
/// VoiceOver cuesta decenas de gestos aunque esté bien armada; decir "quiero
/// ver deportes" cuesta una frase.
///
/// **Ni una palabra de lo que el asistente dice la escribe un modelo.** Todo
/// sale del texto literal de la página o de un número que contó este código.
/// Jev elige entre opciones enumeradas —lo único que hace de forma confiable,
/// medido: 500 ms y acierta— y nunca redacta. Así lo peor que puede pasar es
/// que el asistente cite algo que no servía; nunca que invente algo que no
/// estaba.
///
/// Y cuando duda, pregunta. Medido sobre aerolineas.com.ar con un objetivo
/// vago: Jev pone el destino correcto primero (0,63) pero no sabe si
/// corresponde actuar (0,47 contra 0,53). Navegando sola, esa duda es un
/// fracaso silencioso; conversando, es un turno más.
@MainActor
@Observable
final class Assistant {

    struct Turn: Identifiable, Sendable {
        enum Who: Sendable { case person, jef }
        let id: String
        let who: Who
        let text: String
    }

    /// Lo que el asistente propuso cuando no estuvo seguro, esperando un sí.
    struct Offer: Sendable {
        let goal: String
        let options: [Action]
    }

    private(set) var turns: [Turn] = []
    private(set) var working = false
    /// Un turno en curso, de punta a punta: desde el pedido hasta que las
    /// opciones quedaron puestas. `working` baja y sube entre pasos.
    private(set) var inTurn = false
    /// El próximo anuncio corta lo que se esté diciendo. Ver `heard`.
    private var interruptNext = false
    private(set) var offer: Offer? {
        didSet { Registro.anotar("botones", ["opciones": offer?.options.map(\.label) ?? []]) }
    }
    /// Lo último que dijo, para anunciarlo y para que la pantalla lo muestre
    /// aunque VoiceOver se haya comido el anuncio.
    private(set) var latest = ""

    private let analyzer: PageAnalyzer?
    /// Quien redacta. Jev elige, no escribe; para contestar una pregunta
    /// sobre lo que la página dice hace falta alguien que redacte, y toda
    /// afirmación suya termina en una cita que este código verifica.
    private let answerer: Answerer?
    private var counter = 0
    /// Lo que ya se tocó en este turno. Un asistente que abre un buscador, lo
    /// cierra y lo vuelve a abrir no está avanzando: está oscilando, y quien
    /// no ve sólo escucha que pasan cosas.
    private var touched: Set<String> = []

    /// Cuántos pasos puede dar sin que la persona vuelva a hablar.
    ///
    /// Corto a propósito. Un asistente que encadena diez pasos en silencio es
    /// exactamente lo que alguien que no ve no puede seguir.
    private static let maxSteps = 4

    /// Por debajo de esto no toca: ofrece y espera. Es el umbral que separa
    /// "sé a dónde ir" de "me parece" — ver la nota de arriba.
    private static let sureEnough = 0.7

    /// Quien entiende el pedido. Ver `Router.swift` para por qué no es una
    /// lista de frases.
    private let router: Router?

    /// Los resultados que no entraron en los tres primeros.
    private var pending: [Result] = []
    /// Lo último que el asistente hizo en esta página, para que las opciones
    /// que siguen no ofrezcan lo mismo otra vez.
    private var lastDone: String?
    /// Los titulares que se acaban de leer, por posición: son los que la
    /// persona tiene en la cabeza, así que son los que se ofrecen abrir.
    private var lastChunk: Range<Int>?
    /// Sube cada vez que se toca "Otra cosa": el panel lleva el cursor al
    /// campo de escribir.
    private(set) var inputRequests = 0

    /// Lo que quedaba de la tarea cuando se frenó a preguntar. "Quiero entrar
    /// a ANSES y pedir un turno" muestra los resultados de ANSES y se guarda
    /// el turno: en cuanto la persona elige, sigue sola.
    private var waiting: String?
    /// El último pedido escrito, para "Intentar de nuevo".
    private var lastRequest: String?
    /// El de antes, para entender el de ahora: "¿y el oficial?".
    private var previousRequest: String?
    /// Algo de este turno salió mal: el camino sigue con "Intentar de nuevo".
    private var failedTurn = false
    /// Lo que hay de verdad detrás de cada sugerencia. El botón dice
    /// "Abrir «…»"; lo que se toca es el control real de la página, con su id
    /// y su nombre. Rearmarlo con otro id lo rompía: el motor buscaba en la
    /// página un control que no existía, y se oía "Abriendo Abrir «…»" y "ya
    /// no está".
    private var targets: [String: Action] = [:]
    /// Una pregunta que se buscó en internet y espera a que la persona elija
    /// un resultado: "¿a cuánto está el blue?" se contesta en el sitio que
    /// elija, en vez de describir el sitio.
    private var pendingQuestion: String?
    /// Una prueba anti-robot que tiene que resolver la persona, y lo que se
    /// retoma cuando la resuelve. El asistente no la resuelve —no puede, y
    /// no debe—, pero tampoco corta el camino: pide que la resuelvan y sigue.
    private var challenge: Challenge?
    private struct Challenge {
        enum Resume { case question(String), rest(String), look }
        let url: String
        let resume: Resume
    }
    static let solvedID = "jef-ya-resuelta"

    /// La dirección de la última página que se contó. Si la página cambia
    /// sola y queda en otra, hay que decirlo.
    private var knownURL: String?
    /// El campo cuyo valor se le pidió a la persona: lo próximo que escriba
    /// va ahí. Ver `ask`.
    private var awaitingField: Action.Field? {
        didSet { awaiting = awaitingField.map(Self.spoken) }
    }
    /// El nombre del campo que espera su dato, para que el campo de escribir
    /// lo diga en vez de "¿Qué querés hacer?".
    private(set) var awaiting: String?
    /// Campos ya completados, para no volver a ofrecerlos.
    private var filledFields: Set<String> = []
    /// Las preguntas que siguen a una respuesta, como botones.
    private var nextQuestions: [String] = []
    /// Una pregunta que la página no contestó: se ofrece buscarla afuera.
    private var searchInstead: String?

    init(
        analyzer: PageAnalyzer?,
        answerer: Answerer? = Answerer.fromEnvironment(),
        router: Router? = Router.fromEnvironment()
    ) {
        self.analyzer = analyzer
        self.answerer = answerer
        self.router = router
        // Antes de que la persona diga nada, ya hay por dónde empezar. Al
        // abrir la app por primera vez no había un solo botón, y para quien
        // escribir le cuesta, eso era no poder empezar.
        offer = Offer(goal: "", options: Self.starters)
    }

    /// Ejemplos de pedido, como botones: tocarlos es pedirlos.
    ///
    /// Son los mismos del texto de bienvenida. Además de servir, enseñan qué
    /// se le puede pedir al asistente, que es lo que no sabe quien llega.
    static let starters: [Action] = [
        // Directo, sin lista de resultados: el sitio de un ejemplo propio no
        // hay que adivinarlo.
        .link(id: "res-inicio-lanacion", label: "Llevame a La Nación", href: "https://www.lanacion.com.ar", region: "main"),
    ] + [
        "¿A cuánto está el dólar hoy?", "¿Cómo va a estar el tiempo mañana?",
    ].map { .link(id: askPrefix + $0, label: $0, href: "", region: "main") }

    /// Un botón cuyo id empieza así es un pedido ya escrito.
    static let askPrefix = "jef-pedir:"

    /// Alcanza con uno de los dos. El ruteador solo ya sirve para llegar a
    /// algún lado desde la nada; el analizador es para elegir adentro de una
    /// página que ya está abierta.
    var isAvailable: Bool { analyzer != nil || router != nil }

    /// `aloud`, cuando lo que se escucha tiene que decir más que lo que se
    /// ve: una lista de opciones que en pantalla ya son botones.
    private func say(_ text: String, aloud: String? = nil) {
        counter += 1
        turns.append(Turn(id: "t\(counter)", who: .jef, text: text))
        latest = text
        Registro.anotar("turno", ["quien": "jef", "texto": text])
        // Dicho en voz alta. Es la única manera de que alguien que no ve se
        // entere de lo que el asistente hizo mientras lo hace.
        Voz.decir(Self.forEar(aloud ?? text), interrumpir: interruptNext)
        interruptNext = false
    }

    private func heard(_ text: String) {
        // Lo primero que se diga después de un pedido corta lo que quedaba
        // sonando del anterior. En cola, "Volviendo" llegó a sonar dos minutos
        // después de pedirlo, detrás de un resumen que ya no importaba.
        interruptNext = true
        counter += 1
        turns.append(Turn(id: "t\(counter)", who: .person, text: text))
        Registro.anotar("turno", ["quien": "persona", "texto": text])
    }

    func clear() {
        turns = []
        offer = nil
        latest = ""
    }

    /// Lo que la persona pidió.
    /// `shown`: lo que queda escrito como dicho por la persona, cuando el
    /// pedido salió de un botón. "buscá en internet: …" no lo dijo nadie; lo
    /// que tocó fue "Buscarlo en internet".
    func ask(_ goal: String, on reader: ReaderModel, shown: String? = nil) async {
        let goal = goal.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !goal.isEmpty, !working else { return }
        inTurn = true
        defer { inTurn = false }
        heard(shown ?? goal)
        offer = nil
        touched = []
        lastDone = nil
        failedTurn = false
        pendingQuestion = nil
        nextQuestions = []
        searchInstead = nil
        previousRequest = lastRequest
        lastRequest = goal
        defer { closeTurn(on: reader) }

        // Se preguntó "¿Qué pongo en DNI?" y esto es la respuesta: va directo
        // a ese campo de la página, sin pasar por el ruteador. Antes el
        // asistente no recordaba que estaba esperando un dato, y un DNI
        // suelto tenía que adivinarse de nuevo en la nube.
        if let field = awaitingField {
            awaitingField = nil
            if Self.looksLikeValue(goal) {
                working = true
                reader.fill(field, with: goal)
                try? await Task.sleep(for: .milliseconds(700))
                working = false
                filledFields.insert(field.id)
                // Sin repetir el dato: un DNI dicho en voz alta en la calle no.
                say("Listo, escrito en \(Self.spoken(field)).")
                return
            }
        }

        // Una dirección es una dirección. Buscarla adentro de la página —que
        // es lo que hacía— termina ofreciendo "¿querés que vaya a Inicio?"
        // cuando lo que se pidió fue google.com.
        if let url = ReaderModel.normalize(goal), goal.contains(".") , !goal.contains(" ") {
            say("Abriendo \(Self.bare(url.host() ?? "") ?? goal).")
            working = true
            reader.address = goal
            await reader.go()
            working = false
            await landed(reader)
            return
        }

        // Qué quiere, decidido por un modelo con un esquema cerrado.
        //
        // Antes había acá una lista de expresiones regulares que escribí yo, y
        // la medición la refutó: 5 de 60 pedidos reales, con dos de esos cinco
        // mal resueltos. El mismo set con el Router da 46. "Ayudame a navegar
        // en esta página" ya no termina en "¿querés que vaya a Geografía?".
        // También —y sobre todo— cuando no hay ninguna página abierta. Antes
        // acá había un atajo que llamaba a arrive() con la frase cruda, y se
        // adelantaba al ruteador justo en el primer turno: "quiero entrar a
        // anses y pedir un turno" terminaba buscando esa frase entera en el
        // buscador, que devuelve blogs. Ruteada, la búsqueda es "anses" y el
        // segundo resultado es anses.gob.ar. Se vio en el simulador.
        if let router {
            working = true
            let state = Router.state(page: reader.page, reading: readingProgress(reader.page), previous: previousRequest)
            let decision: Router.Decision?
            do { decision = try await router.decide(goal, state: state) }
            catch Router.RouterError.transport {
                working = false
                say("Sin conexión. No puedo entender lo que pedís sin internet.")
                return
            }
            catch { decision = nil }
            working = false

            if let decision {
                await carry(decision.action, of: decision, goal: goal, on: reader)
                // El límite se dice aunque la acción sea otra. "Entrá a
                // Mercado Libre y comprame pilas" vuelve como ir + comprar:
                // se navega, Y se aclara qué parte no voy a hacer y hasta
                // dónde sí llego. Callarlo es prometer una compra.
                if decision.action != .noPuedo, let limit = decision.limit {
                    say(Self.cannot(limit))
                    if let offer = Self.insteadOffer(limit, arrived: reader.page != nil) { say(offer) }
                }
                // El segundo pedido de una frase que traía dos: "resumime y
                // después entrame a la de Milei". Descartarlo en silencio era
                // uno de los errores que la medición encontró.
                if let next = decision.then, !working {
                    await carry(next, of: decision, goal: goal, on: reader)
                }
                // Y lo que falta de la tarea, ahora que ya hay otra página.
                // "Quiero entrar a ANSES y pedir un turno" aterrizaba en ANSES
                // y el turno se perdía: el pedido no sobrevivía al viaje.
                if let rest = decision.rest, !rest.isEmpty {
                    if offer != nil {
                        // Se frenó a preguntar cuál resultado. La tarea espera
                        // a que la persona elija; seguir ahora sería resolver
                        // "pedir un turno" contra la página del buscador.
                        waiting = rest
                        say("Cuando elijas, sigo con: \(rest).")
                    } else {
                        await continueWith(rest, on: reader)
                    }
                }
                return
            }
        }

        // Sin ruteador —no está, o no contestó— y sin página, buscar el pedido
        // tal cual es mejor que decir que no hay página. Pasó en una prueba:
        // la API devolvió "demasiados pedidos" y "clarín" terminó en "Todavía
        // no hay una página cargada".
        guard reader.page != nil else {
            await arrive(goal, on: reader, naming: false)
            return
        }
        await run(goal, on: reader, steps: Self.maxSteps)
    }

    /// Cuántas veces se puede re-rutear una misma tarea en un turno.
    ///
    /// Tres: alcanza para "entrar a ANSES → turnos → solicitar" y corta
    /// cualquier lazo. Un asistente que encadena diez pasos en silencio es
    /// exactamente lo que alguien que no ve no puede seguir.
    private static let maxHops = 3

    /// Seguir con lo que faltaba de la tarea, ya parados en otra página.
    ///
    /// Cada salto se dice en voz alta. Enterarse de que el asistente sigue
    /// haciendo cosas sin avisar es lo mismo que no saber dónde se está.
    private func continueWith(_ rest: String, on reader: ReaderModel) async {
        guard let router else { return }
        var goal = rest
        for _ in 0..<Self.maxHops {
            guard let page = reader.page else { return }
            say("Sigo con: \(goal).")
            working = true
            let state = Router.state(page: page, reading: readingProgress(page))
            let decision = try? await router.decide(goal, state: state)
            working = false
            guard let decision else { return }
            await carry(decision.action, of: decision, goal: goal, on: reader)
            guard let more = decision.rest, !more.isEmpty, more != goal else { return }
            goal = more
        }
    }

    /// Por dónde va la lectura, para que el ruteador lo sepa sin preguntarle
    /// a nadie: "cuánto falta" es un dato del estado, no una pregunta para un
    /// modelo.
    private func readingProgress(_ page: ExtractedPage?) -> (at: Int, of: Int)? {
        guard let page, page.url == readingURL, readingFrom > 0 else { return nil }
        return (at: readingFrom, of: readablePieces(page).count)
    }

    /// Hacer lo que el ruteador decidió.
    ///
    /// Cada rama de acá o llama a algo que ya estaba probado, o dice por qué
    /// no puede. Lo que NO hay es una rama que redacte: todo lo que se dice
    /// sale de una plantilla o del texto literal de la página.
    private func carry(
        _ action: Router.Action, of decision: Router.Decision,
        goal: String, on reader: ReaderModel
    ) async {
        switch action {
        case .ir:
            await arrive(decision.target ?? goal, on: reader, naming: true)

        case .buscar:
            // Una pregunta con una página abierta se contesta primero con esa
            // página, y recién si no está ahí se busca. "¿Y el oficial?"
            // estando en la página del blue armó una búsqueda nueva que
            // mezclaba los dos, y la página lo tenía.
            if let page = reader.page, Self.isQuestion(goal), let answerer,
               let answer = try? await answerer.answer(goal, about: Self.saying(page), previous: previousRequest) {
                say(answer.text)
                nextQuestions = answer.questions
                return
            }
            // Buscar estando parado en un sitio es buscar EN ese sitio.
            // Mandarlo al buscador de internet lo saca de donde acaba de
            // llegar, que es justo lo que no pidió.
            if let page = reader.page,
               let form = page.actions.first(where: { $0.kind == .form && Self.isSearch($0) }),
               let field = (form.fields ?? []).first(where: { $0.type != "hidden" && !$0.isSecure }) {
                let what = decision.target ?? goal
                let site = Self.bare(URL(string: page.url)?.host() ?? "") ?? page.displaySite
                let before = page.url
                working = true
                say("Buscando \(what) en \(site).")
                reader.fill(field, with: what)
                try? await Task.sleep(for: .milliseconds(700))
                await reader.submit(form)
                working = false
                // La búsqueda del sitio puede no responder: la de Mercado
                // Libre no hizo nada con el envío, y el asistente volvía a
                // describir la portada como si hubiera buscado. Entonces se
                // busca en internet, con el sitio en la consulta.
                if reader.page?.url == before {
                    say("La búsqueda de \(site) no respondió. Busco en internet.")
                    await arrive("\(what) \(site)", on: reader, naming: false)
                    return
                }
                await landed(reader)
                return
            }
            if Self.isQuestion(goal) { pendingQuestion = goal }
            await arrive(decision.target ?? goal, on: reader, naming: false)

        case .abrir:
            // Una referencia —"la segunda", "el del paro"— se resuelve contra
            // lo que la página ofrece de verdad. El modelo nombra; la lista
            // de destinos la pone la página, nunca él.
            await run(decision.reference ?? goal, on: reader, steps: Self.maxSteps)

        case .leer:
            guard let page = reader.page else { return }
            readingFrom = 0
            readAloud(page)

        case .seguir:
            guard let page = reader.page else { return }
            readAloud(page)

        case .resumir:
            guard let page = reader.page else { return }
            // "La nota" en una portada: no hay nota abierta. Resumir la portada
            // sin decirlo hacía creer que se había abierto.
            let flat = goal.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
            if flat.contains("nota"), readsHeadlines(page) {
                say("Todavía no hay una nota abierta: estás en la portada de \(page.displaySite). ¿Cuál abro?")
                lastDone = Self.readID
                lastChunk = 0..<min(3, Self.headlines(of: page).count)
                return
            }
            working = true
            await summarize(page)
            working = false

        case .responder:
            guard let page = reader.page else { return }
            // Si lo que pregunta es por dónde va la lectura, la respuesta ya
            // está contada acá: no hay por qué pagar un viaje a la nube.
            if let progress = readingProgress(page), Self.asksProgress(decision.question ?? goal) {
                say("\(readingUnit(page)) \(progress.at) de \(progress.of).")
                return
            }
            working = true
            await reply(decision.question ?? goal, about: page)
            working = false

        case .completar:
            await complete(decision, goal: goal, on: reader)

        case .enviar:
            guard let page = reader.page,
                  let form = page.actions.first(where: { $0.kind == .form && !($0.fields ?? []).isEmpty })
            else { say("Acá no hay un formulario para enviar."); return }
            // La lista blanca de siempre: se envía sólo cuando se puede
            // PROBAR que es una búsqueda. Un botón que dice "Continuar" y
            // cobra pasa cualquier lista negra.
            guard Self.isSearch(form) else {
                say("Esto no lo envío yo: puede cobrar, contratar o dar de alta algo. El botón «\(form.submit ?? "enviar")» queda para vos.")
                return
            }
            working = true
            say("Enviando.")
            await reader.submit(form)
            working = false
            await landed(reader)

        case .volver:
            await goBack(on: reader)

        case .orientar:
            guard let page = reader.page else {
                say("Puedo abrir sitios, buscar, leerte páginas, resumirlas y contestar lo que dicen. Para empezar, un sitio o algo para buscar; o una de estas opciones.")
                offer = Offer(goal: "", options: Self.starters)
                return
            }
            // Corto: dónde, y qué es esto. Contar la portada entera otra vez
            // no contestaba "no entiendo, ¿dónde estoy?".
            say("Estás en «\(page.sectionTitle)», \(page.displaySite). Arriba está la página; acá abajo, la conversación con JEF: se le pide algo escribiendo, o se toca una opción.")

        case .noPuedo:
            // Un límite no es el final del camino: es un traspaso. Se dice
            // qué parte no hago, y enseguida hasta dónde sí llego — porque
            // quien no ve necesita saber qué le queda por delante, no sólo
            // que algo falló.
            say(Self.cannot(decision.limit))
            if let offer = Self.insteadOffer(decision.limit, arrived: reader.page != nil) {
                say(offer)
            }
        }
    }

    /// Lo que el asistente no sabe hacer, dicho por el código.
    ///
    /// El modelo elige un motivo de una lista cerrada; la frase la escribe
    /// esta función. Si el motivo fuera texto libre del modelo, sería texto
    /// del modelo leído en voz alta, que es justo lo que no hacemos.
    static func cannot(_ limit: Router.Limit?) -> String {
        switch limit {
        case .historial:  return "El historial y las pestañas no los manejo yo."
        case .ajustes:    return "El tamaño de la letra se cambia en los ajustes del teléfono, en Accesibilidad. Desde acá no lo cambio."
        case .compartir:  return "Todavía no sé compartir ni copiar enlaces."
        case .otroSitio:  return "Eso está en otro sitio."
        case .comprar:    return "La compra la hacés vos: confirmar un pago no es algo que yo vaya a hacer en tu nombre."
        case .pagar:      return "Pagar y cargar datos de tarjeta lo hacés vos. Eso no lo toco."
        case .otra, nil:  return "Eso puntual no lo sé hacer."
        }
    }

    /// Hasta dónde sí llego.
    ///
    /// La mitad que importa. "No puedo comprar" a secas deja a la persona
    /// parada; "no compro, pero te llevo, te busco el producto, te leo los
    /// precios y reviso el pedido antes de que confirmes" la deja adentro de
    /// la tarea. El asistente no cierra caminos: los entrega.
    static func insteadOffer(_ limit: Router.Limit?, arrived: Bool) -> String? {
        switch limit {
        case .comprar:
            return arrived
                ? "Sí puedo buscarte el producto, leerte los precios y repasar el pedido antes de que toques comprar."
                : "Sí puedo llevarte hasta el sitio, buscarte el producto y leerte los precios. ¿Arranco por ahí?"
        case .pagar:
            return "Sí puedo llenar los datos que no son de tarjeta, leerte lo que dice el formulario y repasarlo antes de confirmar."
        case .otroSitio:
            return "Decime a cuál y te llevo."
        case .ajustes, .compartir, .historial:
            return "Mientras tanto puedo seguir leyéndote la página, resumirla o llevarte a otro lado."
        case .otra, nil:
            return nil
        }
    }

    /// "¿Cuánto falta?" sobre una lectura en curso. Es lo único que se
    /// pregunta sobre el ESTADO y no sobre la página, y la respuesta está
    /// contada acá: mandarlo a un modelo es pagar por un dato propio.
    static func asksProgress(_ question: String) -> Bool {
        let text = question.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
        return text.range(of: "cuanto falta|cuanto queda|cuanto (mas )?hay|en que parte (voy|estoy)|cuantos parrafos",
                          options: .regularExpression) != nil
    }

    /// Escribir en un campo, con el campo verificado contra la página.
    ///
    /// La verificación existe porque la medición encontró esto: "capital
    /// federal", dicho en una página cuyos campos son usuario, clave y dni,
    /// se rutea como completar con field="usuario". Escribir "capital
    /// federal" adentro del campo de usuario, en un formulario que la persona
    /// no ve, es peor que no hacer nada. Si el campo que nombró el modelo no
    /// existe de verdad, se pregunta.
    private func complete(_ decision: Router.Decision, goal: String, on reader: ReaderModel) async {
        guard let page = reader.page,
              let form = page.actions.first(where: { $0.kind == .form && !($0.fields ?? []).isEmpty })
        else { say("Acá no hay un formulario para completar."); return }

        let fields = (form.fields ?? []).filter { $0.type != "hidden" }
        let named = decision.field.flatMap { wanted in
            fields.first { Self.flatten($0.name) == Self.flatten(wanted) }
                ?? fields.first { Self.distance(Self.flatten($0.name), Self.flatten(wanted)) <= 2 }
        }
        guard let field = named else {
            let names = fields.map(Self.spoken).prefix(4).joined(separator: ", ")
            say("No encuentro ese campo. Los de esta página son: \(names).")
            return
        }
        guard !field.isSecure else {
            // Una contraseña no se dicta y no se escribe por interpretación.
            // Pero la persona tiene que saber que la tarea sigue: se queda en
            // la página, escribe, y volvemos.
            say("La contraseña la escribís vos: ése es el único campo que no toco.")
            say("Te dejo en el formulario. Cuando entres, volvé acá y seguimos.")
            return
        }
        // Un desafío de imagen no se completa por más que sea un campo de
        // texto: el código está dibujado y nadie de este lado lo ve. En el
        // simulador el asistente llegó a preguntar "¿qué pongo en un campo
        // sin nombre?" frente al captcha de ANSES — ofrecerse a hacer algo
        // imposible es peor que decir que no se puede.
        if Self.isChallenge(field) {
            askToSolve(page, image: true)
            return
        }
        guard let value = decision.value, !value.isEmpty else {
            // Y queda esperándolo, con el cursor en el campo de escribir.
            awaitingField = field
            say("¿Qué pongo en \(Self.spoken(field))? Se puede escribir o dictar acá abajo: va directo a ese campo de la página.")
            inputRequests += 1
            return
        }
        working = true
        reader.fill(field, with: value)
        try? await Task.sleep(for: .milliseconds(700))
        working = false
        filledFields.insert(field.id)
        say("Listo, escrito en \(Self.spoken(field)).")
    }

    // MARK: - Llegar a algún lado desde la nada

    /// Un resultado de buscador del que podemos probar que es un resultado.
    struct Result: Sendable {
        let title: String
        let href: String
        var host: String { URL(string: href)?.host()?.lowercased() ?? "" }
    }

    /// Adónde ir cuando todavía no hay página.
    ///
    /// El orden es por costo y por certeza, no por elegancia: una dirección
    /// se carga, y todo lo demás se busca. Lo que NO se hace es pedirle a un
    /// modelo que adivine un dominio — inventar "lanacion.com.ar" es fácil,
    /// inventar "bancoprovinciadesantafe.com.ar" es cómo se manda a alguien
    /// que no ve a un sitio que no es el suyo.
    /// `naming`: la persona nombró un sitio ("llevame a la nación") y no un
    /// tema ("el tiempo en Córdoba"). Sólo entonces se sube el resultado que
    /// se llama como lo que dijo: con un tema, "tiempo" subía tiempo.com —la
    /// Córdoba de España— por encima de todo.
    private func arrive(_ goal: String, on reader: ReaderModel, naming: Bool) async {
        working = true
        defer { working = false }

        // Una dirección no se adivina: la escribió la persona. Si la escribió
        // el ruteador —"buscá mar del plata en wikipedia" volvió una vez como
        // ir a "wikipedia.org"—, no se carga: se busca. Cargada, llevó al
        // portal en inglés con un pedido de donaciones.
        let typed = (lastRequest ?? "").lowercased().contains(goal.lowercased().replacingOccurrences(of: "www.", with: ""))
        if typed, let url = ReaderModel.normalize(goal), goal.contains("."), !goal.contains(" ") {
            say("Abriendo \(Self.bare(url.host() ?? "") ?? goal).")
            reader.address = goal
            await reader.go()
            await landed(reader)
            return
        }

        say("Buscando: \(goal).")
        reader.address = Self.searchURL(for: goal)
        await reader.go()
        guard let found = reader.page.map(Self.results(of:)), !found.isEmpty else {
            // Pasa de verdad: en una consulta comercial la página trae
            // resultados y nosotros extraemos cero. Decirlo es mejor que
            // abrir cualquier cosa.
            say("No encontré resultados para «\(goal)».")
            failedTurn = true
            return
        }

        // Y acá no se elige. Se presenta.
        //
        // Venía abriendo solo el resultado que podía PROBAR que era el sitio
        // nombrado, y esa prueba falló tres veces en una tarde: "anses" es
        // exactamente el dominio de la agencia francesa de seguridad
        // alimentaria; "la nación" también es un diario de Costa Rica; y el
        // resultado que sí era ANSES apuntaba a una página interna con un
        // captcha. Cada arreglo tapaba un caso y dejaba el siguiente.
        //
        // Un buscador nunca navega solo: muestra la lista. El "voy a tener
        // suerte" existió durante veinte años como un botón aparte, opcional,
        // y hasta ahí se acabó. Adivinar por alguien que no puede ver adónde
        // fue a parar es la peor versión de eso.
        //
        // Lo que la prueba de dominio sigue haciendo es ORDENAR: el que
        // coincide va primero. Elegir no.
        present(Self.ranked(goal, among: found, naming: naming), for: goal)
    }

    /// Los resultados en el orden del buscador, con los de otro país al
    /// final; y si la persona nombró un sitio, el que se llama así adelante.
    ///
    /// Al final y no reordenados: con la región puesta el buscador igual dejó
    /// primera la Córdoba de España para "el tiempo mañana en Córdoba". Pero
    /// ordenar todo por país pasaba cualquier .ar por delante de Wikipedia.
    static func ranked(_ request: String, among results: [Result], naming: Bool) -> [Result] {
        // Lo oficial del país, primero. Para "sacar un turno en ANSES" el
        // primer resultado era turnosanses.net, que no es ANSES: a alguien que
        // toca siempre la primera opción, un sitio así le puede pedir datos.
        let official = results.filter(isOfficial)
        let rest = results.filter { !isOfficial($0) }
        let byCountry = official + rest.filter { closer($0) > 0 } + rest.filter { closer($0) == 0 }
        // Un sitio nombrado como PARTE del pedido es el que la persona pidió:
        // "wikipedia" en "mar del plata wikipedia". Va primero, antes que lo
        // oficial: con lo oficial adelante, la Municipalidad le ganaba a
        // Wikipedia. Distinto de un sitio que se llama como el pedido ENTERO
        // —turnosanses.net para "turnos anses"—, que es el truco de esos
        // sitios y va después de lo oficial.
        if let asked = siteNamed(within: request, among: results) {
            return [asked] + byCountry.filter { $0.href != asked.href }
        }
        guard naming, let best = named(request, among: results) else { return byCountry }
        // Lo oficial va antes que cualquier coincidencia de nombre. Para
        // "turnos anses", turnosanses.net se llama EXACTAMENTE como el pedido
        // —es el truco de esos sitios— y le ganaba a argentina.gob.ar.
        let others = byCountry.filter { $0.href != best.href && !isOfficial($0) }
        return official + (isOfficial(best) ? [] : [best]) + others
    }

    /// Lo que se encontró, como botones.
    ///
    /// De a tres, porque tres opciones se retienen de memoria y diez no —y
    /// quien no ve tiene que retenerlas de memoria, no puede barrerlas con la
    /// vista—. El resto queda detrás de "Ver más opciones", que también es un
    /// botón.
    /// `speak`: decirlos. Al volver a una lista ya escuchada, no: la persona
    /// ya los oyó, y releerlos era medio minuto de lo mismo.
    private func present(_ results: [Result], for goal: String, speak: Bool = true) {
        pending = Array(results.dropFirst(Self.shownAtOnce))
        let shown = results.prefix(Self.shownAtOnce)
        // Cada resultado aparece una sola vez: como el botón que se toca,
        // justo debajo de esto. Escritos además como mensajes quedaban
        // repetidos, y los botones lejos del texto que los presentaba.
        // En voz alta sí se dicen, porque quien no ve no los barre con la
        // vista.
        // Sin contar el total: contaba sitios y no resultados, y no
        // coincidía con lo que se ve en la página.
        let found = "Estás en los resultados de «\(goal)»."
        let intro = results.count == 1 ? "Es éste:" : "Los \(shown.count) más probables:"
        // Corta: con los anuncios en cola, una lista larga demora todo lo que
        // viene después. El título recortado y el dominio sin "www.".
        let list = shown.enumerated().map {
            "\($0.offset + 1). \(Self.short($0.element.title, 60)), \(Self.bare($0.element.host) ?? $0.element.host)"
        }
        if speak { say("\(found) \(intro)", aloud: "\(found) \(intro) " + list.joined(separator: ". ")) }
        var options: [Action] = shown.enumerated().map { index, result in
            .link(id: "res-\(index)-\(result.host)", label: "\(result.title) — \(result.host)",
                  href: result.href, region: "main")
        }
        if !pending.isEmpty {
            options.append(.link(id: Self.moreID, label: "Ver más opciones (\(pending.count))",
                                 href: "", region: "main"))
        }
        offer = Offer(goal: goal, options: options)
    }

    /// Cuántos resultados se dicen de una vez.
    static let shownAtOnce = 3
    /// El botón que trae los que faltan. No es un destino: no lleva a ningún
    /// lado, muestra los que quedaron.
    static let moreID = "jef-mas-opciones"

    /// Dónde se busca.
    ///
    /// Google da los mejores resultados para Argentina y es el que va a
    /// quedar. Hoy está DuckDuckGo lite porque Google bloquea: pedirle unas
    /// decenas de búsquedas seguidas desde la misma IP devuelve
    /// `google.com/sorry`, un CAPTCHA adentro de un iframe que no podemos
    /// tocar. Eso le pasa también a quien navega por VPN, por una red
    /// compartida o por ciertas operadoras — y para quien no ve, ese muro no
    /// es una molestia, es el final del camino.
    ///
    /// Está acá arriba y solo para que cambiarlo sea una línea, y para que
    /// el día que haya cadena de respaldo el resto del código no se entere.
    enum Engine: String {
        case duckduckgo, google

        /// La consulta, con el país de la persona.
        ///
        /// Es lo que hace bien un buscador y nosotros no podemos: ordenar por
        /// dónde está quien pregunta. Sin esto, "anses" devuelve la agencia
        /// francesa de seguridad alimentaria entre los primeros, y "banco
        /// nación" el Banco de la Nación del Perú. Medido: con la región
        /// puesta, anses.fr se cae del top y bna.com.ar sube.
        ///
        /// Va el PAÍS y el idioma, nada más. Ni ciudad ni coordenadas: para
        /// ordenar resultados alcanza con eso, y es lo único que hace falta
        /// mandarle a un tercero.
        func url(for query: String) -> String {
            let escaped = query.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? query
            let country = (Locale.current.region?.identifier ?? "AR").lowercased()
            // El idioma del teléfono, no el de la app: ver `Answerer.language`.
            // Con el de la app salía kl=ar-en, que DuckDuckGo no conoce, y la
            // búsqueda quedaba en "All Regions".
            let language = Answerer.phoneLanguage
            switch self {
            case .google:
                return "https://www.google.com/search?q=\(escaped)&gl=\(country)&hl=\(language)"
            case .duckduckgo:
                // DuckDuckGo lo llama kl, y lo escribe al revés: país-idioma.
                return "https://lite.duckduckgo.com/lite/?q=\(escaped)&kl=\(country)-\(language)"
            }
        }
    }

    static var engine: Engine = .duckduckgo

    /// La consulta, si la página es una de resultados del buscador.
    static func searchQuery(of page: ExtractedPage) -> String? {
        guard let parts = URLComponents(string: page.url),
              let host = parts.host?.lowercased(),
              host.contains("duckduckgo.") || (host.contains("google.") && parts.path == "/search"),
              let query = parts.queryItems?.first(where: { $0.name == "q" })?.value,
              !query.isEmpty
        else { return nil }
        return query
    }

    static func searchURL(for query: String) -> String { engine.url(for: query) }

    /// Lo que en una página de buscador es de verdad un resultado.
    ///
    /// Medido, y por eso existe: en Bing y en Startpage los tres primeros
    /// "resultados" que extraíamos eran "Último Momento", "Deportes" y
    /// "Economía" — enlaces de navegación de una tarjeta, no resultados. Si
    /// hubiéramos abierto el primero, abríamos cualquier cosa. La posición
    /// no prueba nada.
    static func results(of page: ExtractedPage) -> [Result] {
        var out: [Result] = []
        var seen = Set<String>()
        var titles = Set<String>()

        func consider(_ title: String, _ href: String) {
            // Los anuncios se sacan por el href, que es donde se declaran.
            // Pedirle a un modelo que "no elija publicidad" sería gastar una
            // probabilidad en algo que se puede demostrar.
            let ad = "aclk\\?|googleadservices|doubleclick|/aclick|bing\\.com/aclick|duckduckgo\\.com/y\\.js|utm_medium=cpc"
            guard href.range(of: ad, options: [.regularExpression, .caseInsensitive]) == nil else { return }
            guard let url = URL(string: href), let host = url.host()?.lowercased() else { return }
            // El buscador no es un resultado de sí mismo.
            let engine = "google\\.|gstatic|googleusercontent|bing\\.|microsoft\\.|duckduckgo\\.|brave\\.|startpage\\."
            guard host.range(of: engine, options: [.regularExpression]) == nil else { return }
            // Ni las copias de prueba de un sitio: web-clarinsandbox.lilax.io
            // salía entre "los 3 más probables" para Clarín.
            guard host.range(of: "sandbox|staging|preprod|cdnedge", options: [.regularExpression]) == nil else { return }
            // Un piso bajo, y el porqué importa. Pedía quince letras para
            // descartar la basura de navegación de Bing —"Deportes",
            // "Economía"— y con eso tiraba el resultado correcto: la ANSES
            // argentina aparece en DuckDuckGo titulada "ANSES", cinco
            // letras. Por ese descarte una persona que pidió ANSES terminó
            // en anses.fr, la agencia francesa de seguridad alimentaria.
            //
            // El intercambio es a favor: lo que se compara es el HOST, no el
            // título, y los hosts se deduplican quedándose con el primero.
            // Un título feo en la lista de tres es un problema cosmético;
            // un resultado que falta es que la persona no llega.
            let clean = title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard clean.count >= 4 else { return }
            guard seen.insert(host).inserted else { return }
            // El mismo título en otro dominio es el mismo resultado: un espejo
            // técnico (cdnedge.lanacion.com.ar) o una copia de prueba
            // (web-clarinsandbox.lilax.io). Ofrecido como "segundo más
            // probable", sólo lo distingue un dominio que nadie reconoce.
            guard titles.insert(flatten(clean)).inserted else { return }
            out.append(Result(title: clean, href: href))
        }

        let byID = Dictionary(page.listings.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        for entry in page.stream ?? [] {
            switch entry.kind {
            case "link":
                if let label = entry.label, let href = entry.href { consider(label, href) }
            case "listing":
                guard let listing = entry.ref.flatMap({ byID[$0] }) else { continue }
                for item in listing.items { if let href = item.href { consider(item.title, href) } }
            default: continue
            }
        }
        return out
    }

    /// El resultado que ES el sitio que la persona nombró, si alguno lo es.
    ///
    /// Se compara contra el DOMINIO y no contra el título, porque el dominio
    /// es lo que distingue al sitio real del que se le parece. Y se compara
    /// aproximado a propósito: quien escribe "la nasion" quiere La Nación, y
    /// Google ya lo entendió — el que no tiene que ser más estricto que
    /// Google somos nosotros.
    ///
    /// Entre los que se parecen gana el mejor rankeado, no el más parecido:
    /// "clarín" está a un carácter de clarins.com, que vende cosméticos, y
    /// no es eso lo que nadie busca desde acá.
    static func named(_ request: String, among results: [Result]) -> Result? {
        let wanted = flatten(request)
        guard wanted.count >= 3 else { return nil }

        // Primero el que ES, sin aproximar nada — y recién después el que se
        // parece. Al revés, "clarín" se iba a clarins.com, que vende
        // cosméticos, sólo porque el buscador lo había puesto más arriba.
        // Una coincidencia exacta nunca puede perder contra un parecido.
        //
        // Entre varios exactos manda el país. Es una RED, no el mecanismo:
        // lo que ordena bien es la región que se le manda al buscador, y esto
        // atrapa lo que se le escape. Visto en el simulador:
        // "anses" coincide exacto con anses.fr, la agencia francesa de
        // seguridad alimentaria, y ahí terminó una persona que pedía la ANSES
        // argentina. El dominio prueba QUÉ sitio es; el país prueba CUÁL de
        // los que se llaman igual.
        let exact = results.filter { labels(of: $0.host).contains(wanted) }
        if !exact.isEmpty {
            // Y entre los exactos del mismo país gana la PORTADA. Quien dice
            // "anses" quiere anses.gob.ar, no
            // servicioswww.anses.gob.ar/Consulta/…, que es adonde fue a parar
            // en el simulador: una página de consulta de estudios con un
            // captcha. Nombrar un sitio es pedir su entrada, no un rincón.
            return exact.min { a, b in
                if closer(a) != closer(b) { return closer(a) > closer(b) }
                if depth(a) != depth(b) { return depth(a) < depth(b) }
                return false
            } ?? exact[0]
        }

        // De acá para abajo la prueba es más débil que la exacta, y se hace
        // contra el NOMBRE del sitio —la parte registrada del dominio— y no
        // contra sus subdominios. Las dos veces que subió el sitio equivocado
        // fue por un subdominio: "mardelplata" en mar-del-plata.wikimapia.org
        // se llevó "buscá mar del plata en wikipedia" a Wikimapia, y
        // "homebanking" en homebanking.bna.com.es mandó "home banking del
        // banco nación" a la filial de España. Y nunca pasa un sitio de OTRO
        // país por delante del orden del buscador.
        func near(_ result: Result) -> Bool { closer(result) > 0 }

        // Un sitio que se llama como algo que la persona dijo: "wikipedia" en
        // "mar del plata en wikipedia", "lanacion" en "diario la nación".
        let words = request.split(whereSeparator: { !$0.isLetter && !$0.isNumber }).map { flatten(String($0)) }
        var said = Set<String>()
        for size in 1...3 where words.count >= size {
            for start in 0...(words.count - size) {
                let gram = words[start..<(start + size)].joined()
                if gram.count >= 4 { said.insert(gram) }
            }
        }
        if let named = results.first(where: { near($0) && siteName(of: $0.host).map(said.contains) == true }) {
            return named
        }

        // Un prefijo cuenta: lanacion contra lanacionmas.
        if let prefix = results.first(where: { result in
            guard near(result), let site = siteName(of: result.host), site.count >= 3 else { return false }
            return site.hasPrefix(wanted) || wanted.hasPrefix(site)
        }) { return prefix }

        // Y por último el error de tipeo. Margen angosto: un carácter cada
        // cinco. Abrir el sitio equivocado a alguien que no ve es peor que
        // no abrir nada.
        let room = max(1, wanted.count / 5)
        return results.first { result in
            guard near(result), let site = siteName(of: result.host) else { return false }
            return distance(wanted, site) <= room
        }
    }

    /// Lo que se escribe, dicho para el oído: "$1.550,00" es "$1.550". Con
    /// la voz rápida, los centavos en cero se oían "coma cero cero".
    static func forEar(_ text: String) -> String {
        text.replacingOccurrences(of: "(\\d),00(?!\\d)", with: "$1", options: .regularExpression)
    }

    /// Un título que entra en un botón, cortado en una palabra y no en la
    /// mitad: "…su evolución patrimo" era un botón que nadie entendía.
    static func short(_ raw: String, _ limit: Int = 70) -> String {
        // Sin las comas de celdas vacías: "Solicitud de Jubilación, , ver
        // sub-trámites".
        let text = raw.replacingOccurrences(of: "(,\\s*)+,", with: ",", options: .regularExpression)
            .replacingOccurrences(of: "\\s{2,}", with: " ", options: .regularExpression)
        guard text.count > limit else { return text }
        let cut = text.prefix(limit)
        let clean = cut.lastIndex(of: " ").map { cut[..<$0] } ?? cut
        return clean.trimmingCharacters(in: .punctuationCharacters.union(.whitespaces)) + "…"
    }

    /// Un dominio como lo escribe una persona: sin "www.". Nil si no hay.
    static func bare(_ host: String) -> String? {
        let clean = host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
        return clean.isEmpty ? nil : clean
    }

    /// Un resultado cuyo sitio se llama como una parte del pedido —una o
    /// varias palabras seguidas, pero no el pedido entero—.
    static func siteNamed(within request: String, among results: [Result]) -> Result? {
        let words = request.split(whereSeparator: { !$0.isLetter && !$0.isNumber }).map { flatten(String($0)) }
        let whole = words.joined()
        var parts = Set<String>()
        for size in 1...3 where words.count >= size {
            for start in 0...(words.count - size) {
                let gram = words[start..<(start + size)].joined()
                if gram.count >= 5, gram != whole { parts.insert(gram) }
            }
        }
        // Lo oficial ya va primero: promoverlo por nombre subía la página de
        // ANSES equivocada —una consulta de estudios con captcha— por encima
        // de "Solicitar turnos".
        return results.first { result in
            closer(result) > 0 && !isOfficial(result) && siteName(of: result.host).map(parts.contains) == true
        }
    }

    /// El nombre del sitio: la parte registrada del dominio, sin
    /// subdominios. `bna` en homebanking.bna.com.es, `wikimapia` en
    /// mar-del-plata.wikimapia.org, `wikipedia` en es.wikipedia.org.
    static func siteName(of host: String) -> String? {
        labels(of: host).last
    }

    /// Sin tildes, sin mayúsculas y sin espacios.
    ///
    /// El artículo NO se saca, y ése era el error: "La Nación" se escribe
    /// `lanacion.com.ar`, con el "la" adentro. Sacándoselo dejaba de
    /// coincidir con lo único contra lo que vale la pena comparar.
    static func flatten(_ text: String) -> String {
        text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
            .filter { $0.isLetter || $0.isNumber }
    }

    /// Un campo que pide copiar un código dibujado.
    ///
    /// Es la clase de muro que no tiene traspaso: el código vive en una
    /// imagen, y ni el extractor ni el asistente lo ven. Los de reCAPTCHA los
    /// agarra `detectChallenge` en el extractor; éste es el casero, que en
    /// ANSES es un input común con un cartel al lado.
    static func isChallenge(_ field: Action.Field) -> Bool {
        let text = (field.name + " " + field.value)
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
        return text.range(of: "captcha|codigo de (la )?imagen|codigo que se muestra|verificacion visual",
                          options: .regularExpression) != nil
    }

    /// El nombre de un campo, dicho como se le dice a una persona.
    ///
    /// Visto en el simulador, en el sistema de ANSES: el asistente anunció
    /// "hay un formulario de 1 campo: ctl00$PlaceContent$txt_Captcha". Ese es
    /// el nombre interno de un control de ASP.NET, y leérselo en voz alta a
    /// alguien que no ve no es un detalle feo: es no haber dicho nada.
    static func spoken(_ field: Action.Field) -> String {
        let name = field.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let code = name.contains("$") || name.contains("ctl00")
            || name.range(of: "^[a-z]+[A-Z_][A-Za-z0-9_]*$", options: .regularExpression) != nil
        if !code, !name.isEmpty { return name }
        // El cartel que la página le puso al lado vale más que su id.
        let fallback = field.value.isEmpty ? "" : field.value
        if !fallback.isEmpty { return fallback }
        switch field.type {
        case "email":    return "correo"
        case "tel":      return "teléfono"
        case "password": return "contraseña"
        case "search":   return "búsqueda"
        default:         return "un campo sin nombre"
        }
    }

    /// Cuán adentro del sitio está esta dirección.
    ///
    /// Subdominios más los tramos de la ruta. `anses.gob.ar` da 0;
    /// `servicioswww.anses.gob.ar/Consulta/Estudios.aspx` da 3. Sirve para
    /// preferir la portada cuando alguien nombra un sitio.
    static func depth(_ result: Result) -> Int {
        let host = result.host.split(separator: ".").map(String.init)
            .filter { !suffixes.contains($0) }
        let path = (URL(string: result.href)?.path ?? "")
            .split(separator: "/").filter { !$0.isEmpty }
        return max(0, host.count - 1) + path.count
    }

    /// Cuán cerca está un sitio de quien pregunta.
    ///
    /// Dos puntos si termina en el país de la persona, uno si es un dominio
    /// sin país (.com, .org), cero si es de otro país. Sirve sólo para
    /// desempatar entre sitios que se llaman igual, que es donde la
    /// coincidencia de nombre ya no alcanza.
    static func closer(_ result: Result) -> Int {
        let parts = result.host.split(separator: ".").map(String.init)
        guard let last = parts.last else { return 0 }
        let home = (Locale.current.region?.identifier ?? "AR").lowercased()
        if last == home { return 2 }
        // Sin país: .com, .org, .net y compañía valen para cualquiera — salvo
        // que el título diga que es de otro. "El tiempo en Córdoba mañana -
        // Meteored España" vive en tiempo.com; "Últimas noticias de Costa Rica
        // | La Nación", en nacion.com. En un dominio del país no se mira: un
        // diario argentino puede titular sobre Perú.
        if ["com", "org", "net", "info", "app", "io", "edu", "int"].contains(last) {
            return mentionsOtherCountry(result.title, home: home) ? 0 : 1
        }
        return 0
    }

    /// Pide a la persona que resuelva la prueba, y deja anotado qué sigue.
    ///
    /// Antes decía "eso no lo puedo resolver yo" y ahí se terminaba el
    /// camino. Lo pidió Daniel: decir qué pide el sitio, que lo resuelva la
    /// persona, y seguir trabajando cuando esté.
    private func askToSolve(_ page: ExtractedPage, image: Bool = false) {
        let resume: Challenge.Resume = pendingQuestion.map { .question($0) } ?? waiting.map { .rest($0) } ?? .look
        pendingQuestion = nil
        waiting = nil
        challenge = Challenge(url: page.url, resume: resume)
        // Corta lo que se esté diciendo: en Mercado Libre el aviso quedó en
        // cola detrás de la descripción de la portada, y nunca llegó a tiempo.
        interruptNext = true
        if image {
            say("El sitio web me pide copiar un código que está dibujado en una imagen, y ésa no la puedo leer. Hay que resolverla en la página, arriba. Cuando esté resuelta, continuamos.")
        } else {
            // Dónde está, siempre: los jueces no sabían cómo llegar a la prueba.
            say("El sitio web me pide resolver una prueba anti-robot. Está en la página, arriba; con VoiceOver, antes de esta conversación. Cuando esté resuelta, continuamos.")
            if page.overlay?.audioChallenge == true {
                say("Tiene una opción de audio, dentro del recuadro de la prueba.")
            }
        }
    }

    /// Si la página todavía pide la prueba.
    static func hasChallenge(_ page: ExtractedPage) -> Bool {
        page.overlay?.kind == .captcha || page.actions.contains {
            $0.kind == .form && ($0.fields ?? []).contains(where: isChallenge)
        }
    }

    /// Lo que se estaba haciendo cuando apareció la prueba.
    private func resume(_ task: Challenge.Resume, on reader: ReaderModel) async {
        guard let page = reader.page else { return }
        switch task {
        case .question(let question):
            working = true
            await reply(question, about: page)
            working = false
        case .rest(let rest):
            await continueWith(rest, on: reader)
        case .look:
            await arrived(page)
        }
    }

    /// Una página que tapa la nota que se quería leer: pedir suscripción,
    /// iniciar sesión, o un captcha.
    static func isWall(_ page: ExtractedPage) -> Bool {
        if let kind = page.overlay?.kind, [.paywall, .login, .captcha].contains(kind) { return true }
        let text = (page.url + " " + page.title).folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
        return text.range(of: "suscri|subscri|registr|login|signin|sign-in|iniciar sesion|/ingresar", options: .regularExpression) != nil
    }

    /// Las raíces de las palabras con contenido: "turno" en "Turnos" y en
    /// "sacar un turno". Para saber si una opción tiene que ver con un pedido.
    static func stems(_ text: String) -> Set<String> {
        let words = text.split(whereSeparator: { !$0.isLetter }).map { flatten(String($0)) }
        return Set(words.filter { $0.count >= 5 }.map { String($0.prefix(5)) })
    }

    /// Si lo escrito es un dato para un campo —un DNI, un mail, un nombre— y
    /// no un pedido nuevo. Por la forma: corto, y sin empezar como un pedido.
    static func looksLikeValue(_ text: String) -> Bool {
        let flat = text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
            .trimmingCharacters(in: .whitespaces)
        guard flat.count <= 60, flat.split(separator: " ").count <= 5, !text.contains("?") else { return false }
        let request = "^(llevame|lleva|abri|abrir|busca|buscar|volve|volver|lee|leer|leeme|resumi|resumir|segui|seguir|que |como |donde |cuando |quien |cual |no |otra|anda|entra|ir |quiero)"
        return flat.range(of: request, options: .regularExpression) == nil
    }

    /// Si el pedido pregunta un dato, en vez de pedir ir a algún lado.
    static func isQuestion(_ text: String) -> Bool {
        let flat = text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
            .trimmingCharacters(in: .whitespaces)
        return text.contains("?") || flat.range(
            of: "^(a )?(que|cual|cuanto|cuanta|como|donde|cuando|quien)\\b", options: .regularExpression
        ) != nil
    }

    /// Un sitio del Estado del país de la persona: .gob.ar, .gov.ar.
    static func isOfficial(_ result: Result) -> Bool {
        let home = (Locale.current.region?.identifier ?? "AR").lowercased()
        return result.host.hasSuffix(".gob.\(home)") || result.host.hasSuffix(".gov.\(home)")
    }

    /// Si un título nombra un país que no es el de la persona.
    static func mentionsOtherCountry(_ title: String, home: String) -> Bool {
        let own = Locale(identifier: "es").localizedString(forRegionCode: home.uppercased()).map(flatten) ?? ""
        let text = " " + title.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
            .map { $0.isLetter ? $0 : " " }.reduce("") { $0 + String($1) } + " "
        return countries.contains { name in
            flatten(name) != own && text.contains(" " + name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil) + " ")
        }
    }

    static let countries = [
        "Argentina", "España", "México", "Chile", "Perú", "Colombia", "Uruguay", "Paraguay",
        "Bolivia", "Venezuela", "Ecuador", "Costa Rica", "Panamá", "Guatemala", "Honduras",
        "El Salvador", "Nicaragua", "Cuba", "República Dominicana", "Puerto Rico", "Estados Unidos",
    ]

    /// Las partes del dominio que nombran al sitio.
    ///
    /// No alcanza con la primera: Wikipedia vive en `es.wikipedia.org`, y
    /// quedarse con "es" es no encontrarla nunca. Se sacan los sufijos, que
    /// no nombran a nadie.
    static let suffixes: Set<String> = [
        "www", "com", "org", "net", "gob", "gov", "edu", "int", "mil", "co",
        "ar", "es", "mx", "cl", "uy", "br", "us", "uk", "io", "app", "info",
    ]

    static func labels(of host: String) -> [String] {
        host.split(separator: ".").map(String.init)
            .filter { !suffixes.contains($0) }
            .map(flatten)
            .filter { !$0.isEmpty }
    }

    /// Cuántos caracteres hay que cambiar para llegar de una a la otra.
    static func distance(_ a: String, _ b: String) -> Int {
        let a = Array(a), b = Array(b)
        guard !a.isEmpty else { return b.count }
        guard !b.isEmpty else { return a.count }
        var previous = Array(0...b.count)
        var current = [Int](repeating: 0, count: b.count + 1)
        for i in 1...a.count {
            current[0] = i
            for j in 1...b.count {
                current[j] = a[i - 1] == b[j - 1]
                    ? previous[j - 1]
                    : 1 + min(previous[j - 1], previous[j], current[j - 1])
            }
            swap(&previous, &current)
        }
        return previous[b.count]
    }


    /// Por dónde va la lectura de esta página.
    ///
    /// Se reinicia sola cuando la página cambia: `readAloud` compara la
    /// dirección, así que volver a una nota no te deja a mitad de otra.
    private var readingFrom = 0
    private var readingURL = ""

    /// La nota, leída de verdad, de a tres párrafos.
    ///
    /// Entera de una vez son sesenta mensajes en el chat y un muro imposible
    /// de recorrer. De a tres, la persona decide si sigue — que es la misma
    /// razón por la que existe el asistente: que el ritmo lo ponga ella.
    ///
    /// Texto literal de la página. Acá no hay modelo ni hay red.
    /// Lo que hay para leer, en orden.
    ///
    /// Los encabezados también se dicen: son los que hacen que una nota larga
    /// tenga forma en vez de ser un chorro de párrafos.
    func readablePieces(_ page: ExtractedPage) -> [String] {
        // Una portada no se lee como una nota: Readability busca UNA nota, y
        // en una portada se queda con cualquier cosa. En el New York Times dio
        // "U.S.. International. Canada. Español. 中文" —el menú de ediciones—
        // como primer párrafo; en La Nación, el pie: el director, el ISSN y la
        // dirección de la empresa. En una portada, leer es leer los titulares.
        if readsHeadlines(page) {
            return Self.headlines(of: page).enumerated().map { "\($0.offset + 1). \($0.element)" }
        }
        return page.blocks.compactMap { block in
            switch block {
            case .heading(_, _, let text): return text.isEmpty ? nil : "— \(text) —"
            case .paragraph(_, let text, _): return text.count >= 40 ? text : nil
            case .quote(_, let text, _): return text.isEmpty ? nil : text
            case .list(_, _, let items):
                let lines = items.map(\.text).filter { !$0.isEmpty }
                return lines.isEmpty ? nil : lines.prefix(6).joined(separator: ". ")
            default: return nil
            }
        }
    }

    /// Si en esta página se leen los titulares y no el texto: es una
    /// portada, y no una nota que además lista otras notas.
    private func readsHeadlines(_ page: ExtractedPage) -> Bool {
        // Ocho como piso: una página de cotizaciones o una lista de trámites
        // tienen algún título enlazado y no son un diario — ofrecían "Leer
        // los titulares" y leían categorías.
        !Self.isArticle(page) && Self.headlines(of: page).count >= 8
    }

    /// Una nota para leer: al menos dos párrafos largos, estén donde estén.
    ///
    /// Párrafos largos y no sólo muchos caracteres: los recortes de una
    /// página de resultados suman caracteres de sobra y no son una nota. Y en
    /// cualquier lugar, no en los tres primeros: Wikipedia abre con avisos
    /// cortos —"Para otros usos…", "No debe confundirse con La Plata"— y
    /// "leeme la nota" sobre Mar del Plata leía los epígrafes de las fotos
    /// como si fueran titulares de una portada.
    static func isArticle(_ page: ExtractedPage) -> Bool {
        let long = page.blocks.filter {
            if case .paragraph(_, let text, _) = $0 { return text.count >= 160 } else { return false }
        }.count
        // Muchos titulares y pocos párrafos largos es una portada, aunque
        // tenga dos o tres bajadas largas: la de Clarín ofrecía "Leer la
        // nota" primero y leía el menú — "Modo Día/Noche. Suscribite…".
        if headlines(of: page).count >= 15 && long < 6 { return false }
        return long >= 2
    }

    /// Cómo se cuenta lo que se lee.
    private func readingUnit(_ page: ExtractedPage) -> String {
        readsHeadlines(page) ? "Titular" : "Párrafo"
    }

    private func readAloud(_ page: ExtractedPage) {
        if page.url != readingURL { readingURL = page.url; readingFrom = 0 }
        let pieces = readablePieces(page)
        let end = readsHeadlines(page) ? "Fin de los titulares." : Self.isArticle(page) ? "Fin de la nota." : "Fin de la página."

        guard !pieces.isEmpty else {
            say("Esta página no tiene texto para leer.")
            return
        }
        guard readingFrom < pieces.count else {
            say("\(end) Se puede resumir, buscar otra cosa, o volver a empezar.")
            readingFrom = 0
            return
        }

        // De a dos párrafos —los titulares, de a tres: son cortos— y con la
        // posición ADELANTE. Al final se perdía: un pedido nuevo corta lo que
        // quedaba sonando, y lo último era justamente dónde se estaba.
        let size = readsHeadlines(page) ? 3 : 2
        let chunk = pieces[readingFrom..<min(readingFrom + size, pieces.count)]
        let unit = readingUnit(page)
        let first = chunk.startIndex + 1, last = chunk.endIndex
        say(first == last
            ? "\(unit) \(first) de \(pieces.count):"
            : "\(unit == "Titular" ? "Titulares" : "Párrafos") \(first) a \(last) de \(pieces.count):")
        for piece in chunk { say(String(piece.prefix(600))) }
        lastChunk = chunk.indices
        lastDone = Self.readID
        readingFrom += chunk.count
        if readingFrom >= pieces.count { say(end) }
    }

    /// De qué trata la página.
    ///
    /// No es una pregunta sobre un dato: si la página tiene texto, SIEMPRE
    /// hay respuesta. Decir "eso no lo encontré en esta página" —que es lo
    /// que decía sobre un artículo de diecisiete mil caracteres— es falso y
    /// deja a la persona sin nada.
    ///
    /// Por eso hay piso: si el modelo no está, no contesta, o su cita no se
    /// puede verificar, se leen los primeros párrafos tal cual los escribió
    /// la página. Es peor resumen y es cierto al cien por ciento.
    private func summarize(_ page: ExtractedPage) async {
        lastDone = Self.summaryID
        let paragraphs: [String] = page.blocks.compactMap {
            if case .paragraph(_, let text, _) = $0 { return text } else { return nil }
        }

        // Sin resumen, lo que la página dice primero. En una portada son los
        // titulares: su primer párrafo largo es el pie, y "dame un resumen de
        // los titulares" en La Nación terminaba en "Propietario: S.A. LA
        // NACION - Av. del Libertador 8630". Lo vio Daniel en el simulador.
        func readTheOpening(offline: Bool = false) {
            if readsHeadlines(page) {
                say(offline
                    ? "Sin conexión no puedo resumirla, pero te cuento los primeros titulares:"
                    : "Te cuento los primeros titulares:")
                for (index, title) in Self.headlines(of: page).prefix(3).enumerated() {
                    say("\(index + 1). \(title.prefix(160))")
                }
                return
            }
            guard let opening = paragraphs.first(where: { $0.count >= 80 }) else {
                describe(page)
                return
            }
            say(offline
                ? "Sin conexión no puedo resumirla, pero te cuento cómo empieza:"
                : "Te cuento cómo empieza:")
            say(String(opening.prefix(400)))
        }

        guard let answerer else {
            readTheOpening()
            return
        }
        let text = Self.saying(page)
        guard !text.isEmpty else {
            say("Esta página no tiene texto que pueda leer.")
            return
        }
        do {
            guard let answer = try await answerer.answer(
                "Resumí esta página en dos o tres frases, con los hechos concretos: qué pasó, quién, cuándo, las cifras. Si es una cobertura en vivo, lo último que informa. Nada de describir la página («informa sobre…»): los hechos.", about: text
            ) else {
                readTheOpening()
                return
            }
            // Diciendo de qué: "resumime la nota" con la nota sin abrir
            // resumía la portada, y nadie se enteraba de que era la portada.
            // Qué se resume, sin repetir el título entero, que ya se escuchó
            // al llegar: "resumime la nota" con la nota sin abrir resumía la
            // portada sin decirlo.
            let what = readsHeadlines(page) ? "la portada" : Self.isArticle(page) ? "la nota" : "la página"
            say("Resumen de \(what): \(answer.text)")
        } catch Answerer.AnswerError.transport {
            readTheOpening(offline: true)
        } catch {
            readTheOpening()
        }
    }

    /// La persona aceptó lo que el asistente propuso.
    func accept(_ action: Action, on reader: ReaderModel) async {
        guard let chosen = offer else { return }
        // Un toque mientras todavía trabaja no se traga en silencio: los
        // jueces lo marcaron como "toqué y no pasó nada".
        guard !working else {
            Voz.decir("Un momento: estoy terminando lo anterior.", interrumpir: true)
            return
        }
        // Un ejemplo de pedido se pide, tal cual: pasa por el mismo camino que
        // si la persona lo hubiera escrito.
        if action.id.hasPrefix(Self.askPrefix) {
            offer = nil
            await ask(String(action.id.dropFirst(Self.askPrefix.count)), on: reader, shown: action.label)
            return
        }
        offer = nil
        inTurn = true
        defer { inTurn = false }
        heard(action.label)
        lastDone = nil
        failedTurn = false
        nextQuestions = []
        searchInstead = nil
        working = true
        defer { working = false }

        // "Otra cosa": ninguna de las opciones era. Se pregunta y se deja a
        // la persona escribiendo — sin más botones, que es justo lo que no
        // servía.
        if action.id == Self.otherID {
            say("¿Qué otra cosa hacemos? Se puede escribir, o dictar con el micrófono del teclado.")
            inputRequests += 1
            return
        }
        defer { closeTurn(on: reader) }

        // Leer y resumir no llevan a ningún lado: actúan sobre esta página.
        if action.id == Self.readID, let page = reader.page {
            working = false
            readingFrom = 0
            readAloud(page)
            return
        }
        if action.id == Self.continueID, let page = reader.page {
            working = false
            readAloud(page)
            return
        }
        if action.id == Self.backID {
            working = false
            await goBack(on: reader)
            return
        }
        // La persona dice que ya resolvió la prueba: se vuelve a mirar la
        // página, y se sigue o se dice que todavía está.
        if action.id == Self.solvedID {
            await reader.reread()
            working = false
            if let page = reader.page, !Self.hasChallenge(page), let pending = challenge {
                challenge = nil
                say("Listo, ya pasamos la verificación.")
                await resume(pending.resume, on: reader)
            } else {
                say("Todavía veo la prueba en la página. Cuando esté resuelta, continuamos.")
            }
            return
        }
        if action.id == Self.summaryID, let page = reader.page {
            await summarize(page)
            return
        }

        // "Ver más opciones" no lleva a ningún lado: trae los que quedaron.
        if action.id == Self.moreID {
            present(pending, for: chosen.goal)
            return
        }

        // Lo que hay detrás de una sugerencia: el control real de la página.
        let target = targets[action.id] ?? action
        let opensNote = action.id.hasPrefix("sug-")

        // Un resultado de búsqueda es una dirección, no un control de esta
        // página: se carga, no se toca. Tocarlo sería buscar ese elemento
        // adentro de la página de resultados, que es otra cosa.
        if target.href?.isEmpty == false, let href = target.href,
           ReaderModel.normalize(href) != nil,
           action.id.hasPrefix("res-") || opensNote {
            if action.label.hasPrefix("Abrir «") {
                say("Abriendo «" + action.label.dropFirst("Abrir «".count))
            } else {
                say("Abriendo \(Self.bare(URL(string: href)?.host() ?? "") ?? action.label).")
            }
            reader.address = href
            await reader.go()
            working = false
            // Se abrió una nota y se llegó a un muro: decirlo, no presentarlo
            // como el destino. En Clarín el titular llevó a la página de
            // suscripción, de ahí a iniciar sesión, y cada una se describía
            // como si la persona hubiera querido ir ahí.
            if let page = reader.page, Self.hasChallenge(page) {
                askToSolve(page, image: page.overlay?.kind != .captcha)
                return
            }
            if opensNote, let page = reader.page, Self.isWall(page) {
                say("Esa nota es para suscriptores o pide iniciar sesión: el sitio me llevó a su página de ingreso.")
                offer = reader.canGoBack
                    ? Offer(goal: "", options: [.link(id: Self.backID, label: "Volver a la página anterior", href: "", region: "main")])
                    : nil
                return
            }
            // Una pregunta que esperaba sitio: se contesta acá, sin describir.
            if let question = pendingQuestion, let page = reader.page {
                pendingQuestion = nil
                say("En \(page.displaySite).")
                working = true
                await reply(question, about: page)
                working = false
                return
            }
            await landed(reader)
            // Y recién ahora sigue la tarea que estaba esperando que la
            // persona eligiera: "…y pedir un turno".
            if let rest = waiting {
                waiting = nil
                await continueWith(rest, on: reader)
            }
            return
        }

        // Un campo se llena, no se toca. Sin esto, aceptar "Buscar en
        // Wikipedia" volvía a apretar la lupa y a preguntar de nuevo: la
        // persona confirmaba una y otra vez sin que nada se escribiera.
        if let page = reader.page, let field = Self.field(named: target, in: page) {
            await write(field, of: target, goal: chosen.goal, on: reader)
            return
        }

        say(target.kind == .link ? "Abriendo «\(target.label)»." : "Tocando «\(target.label)».")
        await reader.activate(target)
        working = false
        guard !chosen.goal.isEmpty else {
            await landed(reader)
            return
        }
        await run(chosen.goal, on: reader, steps: 1)
    }

    private func run(_ goal: String, on reader: ReaderModel, steps: Int) async {
        guard let analyzer else {
            say("El asistente no está configurado en esta versión.")
            return
        }
        working = true
        defer { working = false }
        var first = true

        for _ in 0..<max(steps, 1) {
            guard let page = reader.page else {
                say("Todavía no hay una página cargada.")
                return
            }
            let options = Self.options(of: page)
            guard !options.isEmpty else {
                say("Esta página no ofrece nada que pueda abrir.")
                return
            }

            let decision: PageAnalyzer.Step
            do {
                decision = try await analyzer.nextStep(goal: goal, page: page, options: options)
            } catch JevClient.JevError.transport {
                // Sin red no hay asistente, y eso se dice — no se disimula
                // con un "no encontré nada".
                say("Sin conexión. No puedo navegar a ningún lado.")
                return
            } catch {
                // Y sólo si fue la red. Con la página recién cargada, "dame
                // los titulares" contestó "Sin conexión": lo que había fallado
                // era otra cosa, y decir que no hay internet cuando hay hace
                // que no se crea nada de lo que sigue.
                say("No pude decidir a dónde ir desde acá. Se puede pedir de otra forma, o tocar una opción.")
                failedTurn = true
                return
            }

            // Una pregunta no se camina, se contesta — y se contesta DONDE
            // LA PERSONA ESTÁ. Preguntar no puede moverte: enterarte de que
            // cambiaste de página sin haberlo pedido es lo más desorientador
            // que le podemos hacer a alguien que no ve.
            //
            // Se decide una sola vez, en el primer paso del turno: una vez
            // que el asistente empezó a caminar, sigue caminando.
            if first && decision.kind == .answer {
                await reply(goal, about: page)
                return
            }
            first = false

            switch decision.move {
            case .done:
                describe(page)
                return

            case .ask, .go where decision.confidence < Self.sureEnough:
                let candidates = decision.ranked.prefix(2).compactMap { index in
                    options.indices.contains(index) ? options[index] : nil
                }
                guard let first = candidates.first else {
                    say("No encontré por dónde seguir para eso.")
                    return
                }
                offer = Offer(goal: goal, options: Array(candidates))
                if candidates.count > 1 {
                    say("No es claro cuál. ¿\(first.label)? También encuentro \(candidates[1].label).")
                } else {
                    say("No es claro cuál. ¿\(first.label)?")
                }
                return

            case .go:
                guard
                    let index = decision.ranked.first,
                    options.indices.contains(index)
                else {
                    say("No encontré por dónde seguir para eso.")
                    return
                }
                let chosen = options[index]

                // Oscilar no es avanzar.
                guard touched.insert(chosen.id).inserted else {
                    say("Sin avance: doy vueltas sobre lo mismo. Probar con otras palabras.")
                    return
                }

                // Un campo se llena, no se toca. Y lo que se escribe sale
                // SÓLO de lo que la persona pidió: si un valor pudiera venir
                // de la página, un sitio podría hacer que JEF escriba lo que
                // se le antoje, y quien no ve no tendría cómo notarlo.
                if let field = Self.field(named: chosen, in: page) {
                    await write(field, of: chosen, goal: goal, on: reader)
                    return
                }

                say("Abriendo \(chosen.label).")
                await reader.activate(chosen)
            }
        }

        await landed(reader)
    }

    /// Escribe en un campo lo que la persona pidió, y para antes de enviar.
    ///
    /// **El asistente no envía formularios.** Llena y se detiene, y el botón
    /// que manda queda para la persona. No es una heurística que se pueda
    /// evadir: no existe una ruta de código por la que JEF apriete "Pagar",
    /// "Confirmar" o "Enviar". Un botón que dice "Continuar" y cobra pasa
    /// cualquier lista negra; un asistente que nunca aprieta, no.
    private func write(
        _ field: Action.Field, of form: Action, goal: String, on reader: ReaderModel
    ) async {
        guard let answerer else {
            say("Campo \(field.name) encontrado, pero no puedo escribir en esta versión.")
            return
        }
        let value: String?
        do {
            value = try await answerer.value(for: field.name, from: goal)
        } catch {
            say("No pude preparar lo que hay que escribir. Probar de nuevo.")
            return
        }
        guard let value else {
            say("Campo \(field.name) encontrado, pero falta el valor. Indicarlo y lo escribo.")
            return
        }

        await reader.type(value, into: field)
        say("Listo, escrito en \(Self.spoken(field)).")

        // Buscar no es comprometerse: es lo que la persona pidió, no cuesta
        // nada y se deshace volviendo. Hacerla buscar el botón ella misma
        // después de pedir "busca Buenos Aires" convierte la regla de
        // seguridad en un estorbo, y una regla que estorba en lo común se
        // termina desactivando en lo importante.
        if Self.isSearch(form) {
            say("Buscando.")
            await reader.submit(form)
            await landed(reader)
            return
        }

        let submit = form.submit?.isEmpty == false ? form.submit! : "el botón de enviar"
        say("Formulario completo. Falta pulsar «\(submit)»: enviar es una decisión tuya, no mía.")
    }

    /// Si este formulario sólo busca.
    ///
    /// Se decide con lo que el DOM dice, nunca preguntándole a un modelo si
    /// algo es peligroso — eso ya se midió en este proyecto y no es
    /// confiable. Y se decide por la afirmativa: se envía sólo cuando se
    /// puede PROBAR que es una búsqueda, no cuando no se detecta peligro. Un
    /// botón que dice "Continuar" y cobra pasa cualquier lista negra; ninguna
    /// lista negra es la defensa acá, lo es la lista blanca.
    static func isSearch(_ form: Action) -> Bool {
        let fields = (form.fields ?? []).filter { $0.type != "hidden" }
        guard !fields.isEmpty else { return false }
        // Una contraseña nunca es una búsqueda.
        guard !fields.contains(where: \.isSecure) else { return false }

        let committing = "pagar|comprar|confirmar|enviar|suscrib|registr|crear cuenta|aceptar|continuar|siguiente|finalizar|reservar|checkout|pay|buy|submit|sign ?up|subscribe"
        let searching = "^(buscar|buscá|busca|search|filtrar|aplicar filtros|ver resultados|mostrar|consultar|go)\\b"
        let label = (form.submit ?? "").trimmingCharacters(in: .whitespaces)
        if label.range(of: committing, options: [.regularExpression, .caseInsensitive]) != nil { return false }

        // Todos sus campos son de búsqueda, o su botón dice que busca.
        let fillable = fields.filter { $0.type != "checkbox" && $0.type != "radiogroup" }
        if !fillable.isEmpty, fillable.allSatisfy(\.isSearch) { return true }
        return label.range(of: searching, options: [.regularExpression, .caseInsensitive]) != nil
    }

    /// El campo que este destino representa, si lo es.
    static func field(named action: Action, in page: ExtractedPage) -> Action.Field? {
        guard action.kind == .form else { return nil }
        let fields = action.fields ?? []
        // El primero que todavía está vacío: es donde va lo que se pidió.
        return fields.first { $0.value.isEmpty && !$0.isSecure && $0.type != "checkbox" }
            ?? fields.first { !$0.isSecure }
    }

    /// Contesta una pregunta sobre lo que la página dice.
    ///
    /// Lo que se puede contar, lo cuenta el código; lo que hay que redactar,
    /// lo redacta el modelo y lo respalda con una cita literal que se
    /// verifica contra la página. Si la cita no aparece, no se dice nada:
    /// para quien no ve, una invención sin verificar es indetectable.
    private func reply(_ question: String, about page: ExtractedPage) async {
        guard let answerer else {
            say("No puedo contestar preguntas en esta versión, pero sí navegar.")
            return
        }
        let text = Self.saying(page)
        guard !text.isEmpty else {
            say("Esta página no tiene texto que pueda leer.")
            return
        }
        do {
            guard let answer = try await answerer.answer(question, about: text, previous: previousRequest) else {
                say("Eso no aparece en esta página.")
                searchInstead = question
                return
            }
            say(answer.text)
            nextQuestions = answer.questions
        } catch Answerer.AnswerError.transport {
            say("Sin conexión. Puedo leer la página, pero no contestar preguntas.")
        } catch {
            // Un error del modelo no es un problema de red, y decir que lo es
            // manda a la persona a revisar el wifi por nada. Pasó: la
            // respuesta venía cortada y el mensaje hablaba de la conexión.
            say("Algo falló de mi lado al contestar. Probar de nuevo, o preguntar de otra forma.")
        }
    }

    /// Lo que la página dice, en su orden y separando el contenido del mobiliario.
    ///
    /// El orden importa y la separación más: volcando primero todas las
    /// acciones —las cotizaciones, la promo de suscripción, las redes, el
    /// menú— y después el contenido, "resumime esta página" contestaba con
    /// una descripción de los muebles: "presenta el valor de distintos tipos
    /// de dólar, ofrece una promoción de suscripción, tiene links a sus redes
    /// sociales". Todo cierto y nada de lo que la persona preguntó.
    ///
    /// Así que el contenido va primero y con su nombre, y el cromo del sitio
    /// va al final, dicho como lo que es. Nada se saca: una cotización sigue
    /// siendo un dato que alguien puede preguntar.
    static func saying(_ page: ExtractedPage) -> String {
        let chromeZones: Set<String> = [
            "header", "banner", "nav", "navigation", "search", "footer", "contentinfo",
        ]
        var content: [String] = []
        var chrome: [String] = []
        let byID = Dictionary(page.listings.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        var placed = Set<String>()

        for entry in page.stream ?? [] {
            let isChrome = chromeZones.contains(entry.zone)
            switch entry.kind {
            case "action":
                guard
                    let action = entry.ref.flatMap({ id in page.actions.first { $0.id == id } }),
                    action.kind != .form, action.unnamed != true
                else { continue }
                placed.insert(action.id)
                if isChrome { chrome.append(action.label) } else { content.append(action.label) }
            case "link":
                guard let label = entry.label else { continue }
                if isChrome { chrome.append(label) } else { content.append(label) }
            case "block":
                let said = entry.block?.plainText ?? ""
                guard !said.isEmpty else { continue }
                if isChrome { chrome.append(said) } else { content.append(said) }
            case "listing":
                guard let listing = entry.ref.flatMap({ byID[$0] }) else { continue }
                if !listing.title.isEmpty { content.append(listing.title) }
                for item in listing.items { content.append(item.spokenLabel) }
            default:
                continue
            }
        }

        // Lo que el recorrido no alcanzó a ubicar, para que nada quede fuera.
        for action in page.actions
        where action.kind != .form && action.unnamed != true && !placed.contains(action.id) {
            chrome.append(action.label)
        }
        // Los formularios, con lo que piden. No estaban: en la página de
        // ingreso del banco el asistente no podía decir qué campos había.
        for form in page.actions where form.kind == .form && !(form.fields ?? []).isEmpty {
            let fields = (form.fields ?? []).filter { $0.type != "hidden" }
                .map { $0.isSecure ? "\(spoken($0)) (contraseña)" : spoken($0) }
            guard !fields.isEmpty else { continue }
            let button = form.submit.map { " — botón «\($0)»" } ?? ""
            content.append("FORMULARIO que pide: \(fields.joined(separator: ", "))\(button)")
        }
        // Un artículo no pasa por el recorrido: su texto vive en los bloques.
        if content.count < 8 {
            for block in page.blocks where !block.plainText.isEmpty { content.append(block.plainText) }
        }

        var out = "PÁGINA: \(page.displaySite) — \(page.sectionTitle)\n\n"
        out += "CONTENIDO DE LA PÁGINA (esto es a lo que la persona vino):\n"
        out += content.joined(separator: "\n").prefix(20000)
        if !chrome.isEmpty {
            out += "\n\nMENÚ, AVISOS Y DATOS AL PASO DEL SITIO (no es el contenido, pero se puede preguntar por esto):\n"
            out += chrome.joined(separator: "\n").prefix(3000)
        }
        return out
    }

    /// Qué se abre, en qué orden: los titulares primero, después el resto de
    /// lo que la página ofrece. La lista que ve el modelo empieza por lo que
    /// una persona quiere de una portada.
    static func candidates(of page: ExtractedPage) -> [Action] {
        let all = options(of: page)
        let headlines = Set(headlines(of: page))
        let first = all.filter { headlines.contains(tidy($0.label)) }
        // Del resto, sólo lo que está en el contenido: "Ya tenés tu tarjeta
        // 365?" y "Correo electrónico" salían como opciones de una nota.
        let chrome: Set<String> = ["header", "banner", "nav", "navigation", "footer", "contentinfo"]
        // Ni pagar, ni suscribirse, ni bajar una app: en Clarín se sugería
        // suscribirse, y en el banco, la app — que no se usa desde acá.
        let paying = "suscri|subscri|premium|comprar|pagar|descarg|app store|google play|apple store"
        // Cinco letras y no doce: "Pedir turno" tiene once, y era justo el
        // botón que servía en la página de turnos de ANSES.
        func useful(_ action: Action) -> Bool {
            action.label.count >= 5 && !chrome.contains(action.region)
                && action.label.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
                    .range(of: paying, options: .regularExpression) == nil
        }
        let rest = all.filter { !headlines.contains(tidy($0.label)) && useful($0) }
        // Y los enlaces que viven adentro de un párrafo —"Ingresá a Solicitud
        // de turnos"—, que no son controles sueltos y no entraban.
        var seen = Set(all.compactMap(\.href))
        var inline: [Action] = []
        for block in page.blocks {
            guard case .paragraph(let id, let text, let links) = block else { continue }
            let units = Array(text.utf16)
            for (index, link) in links.enumerated() {
                let lower = max(0, min(link.start, units.count)), upper = max(lower, min(link.end, units.count))
                let label = String(decoding: units[lower..<upper], as: UTF16.self).trimmingCharacters(in: .whitespaces)
                let action = Action.link(id: "\(id)-l\(index)", label: label, href: link.href, region: "main")
                if useful(action), seen.insert(link.href).inserted { inline.append(action) }
            }
        }
        return Array((first + rest + inline).prefix(40))
    }

    static let readID = "jef-leer"
    static let summaryID = "jef-resumir"
    static let continueID = "jef-seguir"
    static let backID = "jef-volver"
    static let otherID = "jef-otra-cosa"

    // MARK: - El camino, armado

    /// Todo turno termina con opciones.
    ///
    /// Las tres o cuatro cosas más probables desde donde la persona quedó, y
    /// "Otra cosa" al final. Lo pidió Daniel: con VoiceOver se avanza
    /// tocando, sin tener que escribir, y el asistente va armando el camino.
    /// Escribir sigue estando siempre abajo; "Otra cosa" dice además que
    /// ninguna de las opciones era.
    ///
    /// Si el turno ya dejó opciones —los resultados de una búsqueda, lo que
    /// sugirió al llegar, "no es claro cuál"— se les suma "Otra cosa". Si
    /// no, salen de la página y de lo que se acaba de hacer, no de un modelo:
    /// tienen que estar aunque no haya red, y ser las mismas cada vez que se
    /// llega al mismo lugar.
    private func closeTurn(on reader: ReaderModel) {
        let other = Action.link(id: Self.otherID, label: "Otra cosa", href: "", region: "main")
        if let current = offer {
            guard !current.options.contains(where: { $0.id == Self.otherID }) else { return }
            // Completar va primero aunque las opciones las haya armado el
            // modelo: en el banco decía "ingresá tu DNI" y el único botón era
            // "Recuperar usuario y contraseña".
            let waitingFor = Set(awaitingField.map { [$0.id] } ?? [])
            let form = reader.page.map { Self.formOptions($0, except: filledFields.union(waitingFor)) } ?? []
            var options = form + current.options.filter { option in !form.contains { $0.id == option.id } }
            // Volver, aunque las opciones las haya armado el modelo: sin él,
            // salir de una página equivocada obligaba a escribir.
            let isResults = options.contains { $0.id.hasPrefix("res-") }
            if reader.canGoBack, !isResults, !options.contains(where: { $0.id == Self.backID }) {
                options.append(.link(id: Self.backID, label: "Volver a la página anterior", href: "", region: "main"))
            }
            offer = Offer(goal: current.goal, options: options + [other])
            return
        }
        // Después de una falla, lo primero es poder intentarlo otra vez sin
        // escribirlo de nuevo. Antes el único botón era "Otra cosa": para
        // quien escribir le cuesta, ahí se terminaba el camino.
        var options: [Action] = []
        // Después de un dato, lo que probablemente se pregunte después; si la
        // página no lo tenía, buscarlo afuera. El camino sigue sin escribir.
        if reader.page?.overlay?.kind != .captcha {
            options += nextQuestions.map { .link(id: Self.askPrefix + $0, label: $0, href: "", region: "main") }
        }
        if let question = searchInstead {
            options.append(.link(id: Self.askPrefix + "buscá en internet: " + question,
                                 label: "Buscarlo en internet", href: "", region: "main"))
        }
        if failedTurn, let request = lastRequest {
            options.append(.link(id: Self.askPrefix + request, label: "Intentar de nuevo", href: "", region: "main"))
        }
        if let page = reader.page {
            options += followUps(page, canGoBack: reader.canGoBack)
        } else if options.isEmpty {
            options = Self.starters
        }
        // Volver no se cae al recortar: era lo primero que desaparecía.
        let back = options.first { $0.id == Self.backID }
        var kept = Array(options.filter { $0.id != Self.backID }.prefix(back == nil ? 4 : 3))
        if let back { kept.append(back) }
        offer = Offer(goal: "", options: kept + [other])
    }

    /// Lo que sigue, según la página y lo último que se hizo en ella.
    private func followUps(_ page: ExtractedPage, canGoBack: Bool) -> [Action] {
        func option(_ id: String, _ label: String) -> Action {
            .link(id: id, label: label, href: "", region: "main")
        }
        let reading = page.url == readingURL && readingFrom > 0
        let more = reading && readingFrom < readablePieces(page).count
        let summarized = lastDone == Self.summaryID
        var out: [Action] = []

        if challenge != nil || Self.hasChallenge(page) {
            // Por si el sitio no avisa cuando se resuelve: la persona lo dice.
            return [option(Self.solvedID, "Ya la resolví")]
                + (canGoBack ? [option(Self.backID, "Volver a la página anterior")] : [])
        }

        if let query = Self.searchQuery(of: page) {
            // En la página del buscador lo probable es uno de los resultados.
            let found = Self.ranked(query, among: Self.results(of: page), naming: false)
            for (index, result) in found.prefix(3).enumerated() {
                out.append(.link(id: "res-\(index)-\(result.host)", label: "\(result.title) — \(result.host)",
                                 href: result.href, region: "main"))
            }
            return out
        }

        out += Self.formOptions(page, except: filledFields.union(awaitingField.map { [$0.id] } ?? []))

        if readsHeadlines(page) {
            // Recién leídos, lo probable es abrir uno de ésos: son los que la
            // persona tiene en la cabeza.
            if lastDone == Self.readID, let chunk = lastChunk {
                let all = Self.headlines(of: page)
                for index in chunk where all.indices.contains(index) {
                    guard let href = Self.href(ofHeadline: all[index], in: page) else { continue }
                    out.append(.link(id: "sug-titular-\(index)", label: "Abrir «\(Self.short(Self.dekick(all[index])))»",
                                     href: href, region: "main"))
                }
                if more { out.append(option(Self.continueID, "Seguir con los titulares")) }
                return out
            }
            out.append(option(Self.readID, "Leer los titulares"))
            if !summarized { out.append(option(Self.summaryID, "Resumir la portada")) }
        } else if Self.isArticle(page) {
            if more { out.append(option(Self.continueID, "Seguir leyendo")) }
            else if !reading { out.append(option(Self.readID, "Leer la nota")) }
            if !summarized { out.append(option(Self.summaryID, "Resumir la nota")) }
        } else if !readablePieces(page).isEmpty {
            if more { out.append(option(Self.continueID, "Seguir leyendo")) }
            else if !reading { out.append(option(Self.readID, "Leer la página")) }
            if !summarized { out.append(option(Self.summaryID, "Resumir la página")) }
        }
        if canGoBack { out.append(option(Self.backID, "Volver a la página anterior")) }
        // Volver al final y siempre: recortando, era lo primero que se caía.
        let back = out.first { $0.id == Self.backID }
        let rest = out.filter { $0.id != Self.backID }
        return Array(rest.prefix(back == nil ? 3 : 2)) + (back.map { [$0] } ?? [])
    }

    /// Un titular sin su volanta: "Por carta. El secretario de Discapacidad…"
    /// es "El secretario de Discapacidad…". La volanta no es lo que se dijo,
    /// y con el rotor un botón se reconoce por sus primeras palabras.
    static func dekick(_ title: String) -> String {
        guard let range = title.range(of: "^[^.!?]{2,30}\\.\\s+(?=[A-ZÁÉÍÓÚÑ¿¡\"«])", options: .regularExpression),
              title[range].split(separator: " ").count <= 4 else { return title }
        let rest = String(title[range.upperBound...])
        return rest.count >= 20 ? rest : title
    }

    /// Un titular sin la hora de publicación que algunos sitios le pegan:
    /// "Medidas de Milei, Hace 34 min". Leída en voz alta, la hora sonaba a
    /// parte de la noticia.
    static func tidy(_ title: String) -> String {
        title.replacingOccurrences(
            of: "[,.·|-]?\\s*[Hh]ace \\d+\\s*(min|minutos|h|hs|horas|d|días)\\.?\\s*$",
            with: "", options: .regularExpression
        ).trimmingCharacters(in: .whitespaces)
    }

    /// A dónde lleva un titular: el mismo recorrido del que sale
    /// `headlines(of:)`, así que el texto coincide letra por letra.
    static func href(ofHeadline title: String, in page: ExtractedPage) -> String? {
        let byID = Dictionary(page.listings.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        for entry in page.stream ?? [] {
            if entry.kind == "link", entry.label.map(tidy) == title, let href = entry.href { return href }
            if entry.kind == "listing", let listing = entry.ref.flatMap({ byID[$0] }),
               let href = listing.items.first(where: { tidy($0.title) == title })?.href {
                return href
            }
        }
        return nil
    }

    /// Un formulario que no es de búsqueda —el ingreso de un banco— se
    /// completa: ése es el paso que sigue, y no había forma de darlo sin
    /// saber escribir el pedido justo. La contraseña no: ésa es de la persona.
    static func formOptions(_ page: ExtractedPage, except filled: Set<String> = []) -> [Action] {
        guard let form = page.actions.first(where: { $0.kind == .form && !isSearch($0) && !($0.fields ?? []).isEmpty })
        else { return [] }
        let fillable = (form.fields ?? []).filter {
            $0.type != "hidden" && !$0.isSecure && $0.type != "checkbox" && !isChallenge($0) && !filled.contains($0.id)
        }
        return fillable.prefix(2).map { field in
            let name = spoken(field)
            return .link(id: askPrefix + "completá el campo \(name)", label: "Completar «\(name)»", href: "", region: "main")
        }
    }

    /// Volver a la página anterior y decir dónde se quedó. También lo usa el
    /// gesto de escape de VoiceOver: volver siempre suena igual.
    func goBack(on reader: ReaderModel) async {
        guard !working else { return }
        guard reader.canGoBack else { say("No hay a dónde volver: esta es la primera página."); return }
        working = true
        say("Volviendo.")
        await reader.back()
        working = false
        readingFrom = 0
        // Corto: la persona ya estuvo acá. Volver a describir la portada
        // entera eran cuarenta segundos de algo ya escuchado. La página del
        // buscador sí se ofrece como la primera vez: sus resultados son los
        // botones.
        guard let page = reader.page else {
            await landed(reader)
            return
        }
        knownURL = page.url
        if let query = Self.searchQuery(of: page) {
            say("De vuelta en los resultados de «\(query)».")
            present(Self.ranked(query, among: Self.results(of: page), naming: false), for: query, speak: false)
            return
        }
        offer = nil
        say("De vuelta en «\(page.sectionTitle)», \(page.displaySite).")
    }

    /// La página cambió sin que nadie se lo pidiera al asistente: un
    /// captcha que aparece después de cargar, un sitio que redirige, o la
    /// persona tocando la página misma. En Mercado Libre el captcha llegó en
    /// silencio y el asistente seguía hablando de la portada.
    func pageChanged(_ page: ExtractedPage, on reader: ReaderModel) async {
        // La prueba se resolvió: el sitio avanzó, o la sacó de la página. Se
        // sigue solo con lo que se estaba haciendo, aunque la dirección sea
        // la misma — hay sitios que muestran la prueba en la misma dirección.
        if let pending = challenge, !inTurn, !working {
            guard !Self.hasChallenge(page) else { return }
            challenge = nil
            inTurn = true
            defer { inTurn = false }
            interruptNext = true
            say("Listo, ya pasamos la verificación.")
            await resume(pending.resume, on: reader)
            closeTurn(on: reader)
            return
        }
        guard !inTurn, !working, page.url != knownURL else { return }
        inTurn = true
        defer { inTurn = false }
        interruptNext = true
        if page.overlay?.kind == .captcha {
            say("La página cambió.")
            describe(page)
        } else {
            knownURL = page.url
            offer = nil
            say("La página cambió: ahora estás en «\(page.sectionTitle)», \(page.displaySite).")
        }
        closeTurn(on: reader)
    }

    /// Después de cargar: dónde quedó, o que no se pudo.
    ///
    /// Antes el que avisaba era el navegador, con un "No se pudo leer esta
    /// página" que la conversación no mostraba y que el anuncio siguiente
    /// cortaba. La carga la pidió el asistente; el que cuenta cómo salió es él.
    private func landed(_ reader: ReaderModel) async {
        if let page = reader.page {
            await arrived(page)
        } else if case .failed = reader.state {
            say("No pude abrir esa página. Puede ser la conexión o el sitio.")
            failedTurn = true
        }
    }

    /// Llegar a una página, dicho como lo diría una persona.
    ///
    /// Es lo que pidió Daniel al ver la portada del New York Times leída como
    /// una nota, con el menú de ediciones como primer párrafo: "estás en la
    /// portada del New York Times, los titulares son éstos, ¿qué te gustaría
    /// hacer?" — con las opciones como botones.
    ///
    /// Sin modelo (sin red, o sin key) se cae a `describe`, que es plantilla
    /// pero es cierta.
    private func arrived(_ page: ExtractedPage) async {
        // Las opciones eran de la página anterior. En Mercado Libre, frente al
        // "no soy un robot", seguían ofreciéndose "Suscribirme a Meli+" y
        // "Configurar cookies" de la portada.
        offer = nil
        knownURL = page.url
        // Un captcha es el único aviso que es un muro: detrás no hay nada que
        // contar hasta que alguien lo resuelva.
        if page.overlay?.kind == .captcha { describe(page); return }
        if Self.hasChallenge(page) { askToSolve(page, image: true); return }
        challenge = nil

        // La página de resultados del buscador se ofrece como la primera vez:
        // los resultados como botones. Se vuelve a ella —"volvé" desde el
        // sitio que no era— y descripta como una página más decía "hay 6
        // notas, puedo leer una", el vocabulario de la página de la que se
        // venía, con los resultados como texto. Lo vio Daniel en el simulador.
        if let query = Self.searchQuery(of: page) {
            let found = Self.results(of: page)
            if !found.isEmpty {
                present(Self.ranked(query, among: found, naming: false), for: query)
                return
            }
        }

        guard let answerer else { describe(page); return }

        // Cualquier otro aviso se menciona y se sigue. Antes, "si hay un aviso,
        // describilo y pará": el New York Times SIEMPRE tiene el de
        // suscripción, así que el asistente anunciaba "Opciones: Close, Get
        // started" y nunca llegaba a los titulares — que estaban extraídos,
        // ahí abajo. Un aviso de suscripción no impide leer.
        var text = Self.saying(page)
        if let overlay = page.overlay {
            text = "HAY UN AVISO ENCIMA DE LA PÁGINA (\(overlay.kind.title)): \(overlay.text)\n\n" + text
        }
        let candidates = Self.candidates(of: page)
        // En una portada, los titulares que se nombran y los botones son los
        // mismos porque los elige el código: los primeros de la página. Dejando
        // que el modelo eligiera los botones por número, nombraba unos y
        // ofrecía otros.
        let lead = readsHeadlines(page) ? Array(Self.headlines(of: page).prefix(4)) : []
        let spoken = lead.map(Self.dekick)
        if !lead.isEmpty {
            text = "TITULARES PRINCIPALES, EN ORDEN (nombrá estos y en este orden, nada más de la portada): "
                + spoken.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: " / ") + "\n\n" + text
        }
        working = true
        let orientation = try? await answerer.orient(
            page: text, candidates: candidates.map(\.label), goal: lastRequest
        )
        working = false
        guard let orientation else { describe(page); return }

        say(orientation.text)
        let options: [Action] = orientation.suggestions.compactMap { suggestion in
            switch suggestion.kind {
            case .abrir:
                guard let number = suggestion.number, candidates.indices.contains(number - 1) else { return nil }
                let target = candidates[number - 1]
                targets["sug-\(target.id)"] = target
                return Action(
                    // El título de lo que abre, no el del modelo: en Clarín
                    // un botón que decía "Abrir noticia de la visita de León
                    // XIV" abría otra nota, y "Abriendo www.clarin.com" no
                    // dejaba notarlo.
                    id: "sug-\(target.id)", kind: target.kind, label: "Abrir «\(Self.short(target.label))»", href: target.href,
                    fields: nil, submit: nil, notices: nil, region: target.region,
                    unnamed: nil, cluster: nil, primary: nil, fresh: nil
                )
            case .leer:
                return .link(id: Self.readID, label: suggestion.label, href: "", region: "main")
            case .resumir:
                return .link(id: Self.summaryID, label: suggestion.label, href: "", region: "main")
            }
        }
        // En una nota, primero lo de esta nota: leerla, resumirla. Si no, el
        // primer botón —el que toca quien toca siempre el primero— la sacaba
        // a otra nota antes de haberla escuchado.
        var ordered = Self.isArticle(page)
            ? options.filter { $0.id == Self.readID } + options.filter { $0.id == Self.summaryID }
                + options.filter { $0.id != Self.readID && $0.id != Self.summaryID }
            : options
        // En una nota, leerla y resumirla siempre están, y otras notas, una a
        // lo sumo: se ofrecían tres notas ajenas y faltaba "Resumir la nota".
        if Self.isArticle(page), !readsHeadlines(page) {
            let others = ordered.filter { $0.id.hasPrefix("sug-") }.prefix(1)
            ordered = [.link(id: Self.readID, label: "Leer la nota", href: "", region: "main"),
                       .link(id: Self.summaryID, label: "Resumir la nota", href: "", region: "main")] + Array(others)
        }
        if !lead.isEmpty {
            let named: [Action] = lead.enumerated().compactMap { index, title in
                guard let href = Self.href(ofHeadline: title, in: page) else { return nil }
                return .link(id: "sug-titular-\(index)", label: "Abrir «\(Self.short(Self.dekick(title)))»", href: href, region: "main")
            }
            // Lo que el modelo propuso para lo que la persona vino a hacer va
            // primero, si no es uno de los titulares. En la portada de ANSES
            // dijo "para sacar un turno, tenés que ir a la sección Turnos", y
            // los botones eran sólo los primeros titulares: el de Turnos no
            // estaba.
            let hrefs = Set(named.compactMap(\.href))
            // Y sólo si tiene que ver con lo pedido: en Clarín, con "clarín"
            // como pedido, ese lugar lo ocupaba una nota que nadie nombró.
            let asked = Self.stems(lastRequest ?? "")
            let forGoal = ordered.filter {
                $0.id.hasPrefix("sug-") && !hrefs.contains($0.href ?? "") && !Self.stems($0.label).isDisjoint(with: asked)
            }.prefix(1)
            ordered = Array(forGoal) + named + ordered.filter { !$0.id.hasPrefix("sug-") }
        }
        // Una opción por id: dos "leer" con el mismo id eran, para VoiceOver,
        // el mismo botón dos veces con nombres distintos.
        var ids = Set<String>(), labels = Set<String>()
        ordered = ordered.filter { ids.insert($0.id).inserted && labels.insert(Self.flatten($0.label)).inserted }
        if !ordered.isEmpty { offer = Offer(goal: "", options: ordered) }
    }

    /// Dónde quedó la persona y qué hay, sin generar una palabra.
    ///
    /// Esta es la parte que más pesa cuando la página no se recorre. Si nadie
    /// va a pasarle VoiceOver por encima, esto es TODO lo que la persona va a
    /// saber del lugar donde está: no alcanza con el título. Hay que decir
    /// qué clase de página es, cuánto tiene, y qué se puede hacer desde acá.
    ///
    /// Cinco formas, porque son las cinco que encontramos midiendo: algo que
    /// tapa, una portada, una nota, una lista de resultados y un formulario.
    /// La que no cae en ninguna termina en el conteo de opciones, que es
    /// pobre pero es cierto.
    ///
    /// Ni una palabra de acá la escribe un modelo: todo es plantilla, texto
    /// literal de la página y cuentas del código. Un resumen se pide; una
    /// orientación no puede depender de que la red conteste.
    private func describe(_ page: ExtractedPage) {
        knownURL = page.url
        // Lo que tapa va primero: detrás de un muro de cookies no hay nada
        // que hacer, y es justo lo que la persona no puede ver que está ahí.
        if let overlay = page.overlay {
            // Un desafío anti-robot es el único muro que no tiene traspaso:
            // el rompecabezas vive dentro del iframe del proveedor, otro
            // origen, así que no podemos tocarlo ni describirlo. Lo único
            // honesto es decir qué es, que no lo voy a resolver, y que hay
            // salida para otro lado. Medido contra el muro real de Mercado
            // Libre: el detector lo reconoce y avisa que hay opción de audio.
            if overlay.kind == .captcha {
                askToSolve(page)
                return
            }
            // "Aviso de la página tapa la página" se oía roto: el título de un
            // aviso genérico ya dice "página". Se nombra lo que tapa y listo.
            say(overlay.kind == .other
                ? "Hay un aviso encima de la página."
                : "\(overlay.kind.title) encima de la página.")
            if !overlay.choices.isEmpty {
                say("Opciones: \(overlay.choices.map(\.label).prefix(3).joined(separator: ", ")).")
            } else {
                say("No encontré cómo sacarlo, así que esta página queda para vos. Puedo llevarte a otro lado.")
            }
            return
        }

        say("En \(page.sectionTitle) — \(page.displaySite).")

        // 1. Una portada: titulares que se abren.
        let headlines = Self.headlines(of: page)
        if !headlines.isEmpty, !Self.isArticle(page) {
            say("Hay \(headlines.count) \(headlines.count == 1 ? "nota" : "notas"). \(headlines.count == 1 ? "Dice" : "Las tres primeras"):")
            for title in headlines.prefix(3) { say(Self.short(title, 140)) }
            return
        }

        // 2. Una nota para leer. Se pide párrafo largo y no sólo muchos
        //    caracteres: los recortes de una página de resultados suman
        //    caracteres de sobra y no son una nota.
        let paragraphs: [String] = page.blocks.compactMap {
            if case .paragraph(_, let text, _) = $0 { return text } else { return nil }
        }
        if Self.isArticle(page), let opening = paragraphs.first(where: { $0.count >= 160 }) {
            say("Es una nota de \(paragraphs.count) párrafos. Empieza así:")
            say(String(opening.prefix(220)))
            return
        }

        // 3. Una lista de resultados. Es el caso que antes salía como
        //    "Llegué. Estás en Buscar" y no decía cuántos ni cuáles.
        let lists = page.listings.filter(\.isNavigable)
        let items = lists.flatMap(\.items)
        if items.count >= 3 {
            let named = lists.count == 1 ? lists[0].title.trimmingCharacters(in: .whitespaces) : ""
            say(named.isEmpty
                ? "Hay \(items.count) resultados. Los tres primeros:"
                : "\(named): \(items.count). Los tres primeros:")
            for item in items.prefix(3) { say(Self.short(item.title, 140)) }
            return
        }

        // 4. Un formulario: acá no se mira, se completa.
        if let form = page.actions.first(where: { $0.kind == .form && !($0.fields ?? []).isEmpty }) {
            let fields = (form.fields ?? []).filter { $0.type != "hidden" }
            let names = fields.map(Self.spoken).filter { !$0.isEmpty }
            say("Hay un formulario de \(fields.count) \(fields.count == 1 ? "campo" : "campos")\(names.isEmpty ? "" : ": " + names.prefix(4).joined(separator: ", ")).")
            if fields.contains(where: \.isSecure) {
                // Una contraseña no se dicta y no se manda sola.
                say("Incluye una contraseña: ese campo queda sin completar.")
            } else {
                say("Indicar qué poner y lo completo.")
            }
            return
        }

        // 5. Nada de lo anterior. El número igual sirve: saber que hay 40
        //    opciones es distinto de no saber si la página cargó.
        let controls = page.actions.filter { $0.kind != .form }.count
        if controls > 0 {
            say("Esta página tiene \(controls) \(controls == 1 ? "opción" : "opciones"). Indicar qué buscar.")
        } else {
            say("Esta página no ofrece nada para abrir.")
        }
    }

    // MARK: - La tabla

    /// Todo lo que la página deja tocar o abrir, esté o no en la pantalla.
    ///
    /// Es la ventaja que JEF tiene y que un agente genérico no: su inventario
    /// mira la página entera. Medido contra el de browser-use en
    /// aerolineas.com.ar: el suyo ve 35 controles, los de arriba de todo, y
    /// "MI RESERVA" no está entre ellos; el nuestro ve 57 y sí lo tiene.
    static func options(of page: ExtractedPage) -> [Action] {
        var out: [Action] = []
        var seen = Set<String>()

        func add(_ action: Action) {
            let key = action.href ?? action.id
            guard seen.insert(key).inserted, !action.label.isEmpty else { return }
            out.append(action)
        }

        for action in page.actions where action.unnamed != true {
            // Un formulario es un destino: significa "escribí acá". Sin él,
            // "busca Buenos Aires" no tiene a dónde ir y el asistente termina
            // abriendo y cerrando la lupa.
            guard action.kind != .form || !(action.fields ?? []).isEmpty else { continue }
            add(action)
        }
        let byID = Dictionary(page.listings.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        for entry in page.stream ?? [] {
            switch entry.kind {
            case "link":
                guard let label = entry.label, let href = entry.href else { continue }
                add(.link(id: entry.id, label: label, href: href, region: entry.zone))
            case "listing":
                guard let listing = entry.ref.flatMap({ byID[$0] }) else { continue }
                for (index, item) in listing.items.enumerated() {
                    guard let href = item.href else { continue }
                    add(.link(id: "\(listing.id)-\(index)", label: item.title, href: href, region: entry.zone))
                }
            default:
                continue
            }
        }
        // Jev admite 255 opciones por pregunta. Medido, no documentado.
        return Array(out.prefix(240))
    }

    /// Los titulares de esta página: un link que además es encabezado, o un
    /// ítem de listado con nombre largo que abre otra página. La misma regla
    /// que decide si algo es una portada.
    static func headlines(of page: ExtractedPage) -> [String] {
        var out: [String] = []
        var seen = Set<String>()
        let byID = Dictionary(page.listings.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        for entry in page.stream ?? [] {
            // Veinte letras como piso: "Medidas de Milei" y "Dólar hoy" son
            // etiquetas de sección del ticker, no notas.
            if entry.kind == "link", entry.level != nil, entry.href != nil, let label = entry.label.map(tidy),
               label.count >= 20 {
                if seen.insert(label).inserted { out.append(label) }
            }
            if entry.kind == "listing", let listing = entry.ref.flatMap({ byID[$0] }) {
                for item in listing.items where item.href != nil && item.title.count >= 25 {
                    let title = tidy(item.title)
                    if seen.insert(title).inserted { out.append(title) }
                }
            }
        }
        return out
    }
}
