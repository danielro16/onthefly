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
    /// El formulario cuyo botón se ofreció para que lo toque la mano: el que
    /// se aprieta al tocar "Pulsar «…»". Ver `submitAsked`.
    private var pendingSubmit: Action?
    /// Lo que Gemini marcó como ruido al llegar a esta página, por id: no se
    /// sugiere. Jev lo sigue viendo al navegar. Ver `arrived`.
    private var noisy: (url: String, ids: Set<String>) = ("", [])

    /// Cuántos pasos puede dar sin que la persona vuelva a hablar.
    ///
    /// Corto a propósito. Un asistente que encadena diez pasos en silencio es
    /// exactamente lo que alguien que no ve no puede seguir.
    private static let maxSteps = 4

    /// Por debajo de esto Jev no toca solo: decide Gemini y, si tampoco, la
    /// persona. Medido con el banco multilingüe; vive en `criterios.json`.
    private static var sureEnough: Double { Criterios.actuales?.umbrales["cual_confianza"] ?? 0.5 }

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
    /// Lo que la persona vino a hacer, en sus palabras: «quiero sacar un turno
    /// en ANSES». Lo declara ella y dura hasta que pida otra cosa —lo dice el
    /// ruteador—; un «volvé» o un «jubilación» no la pisan. La reciben el
    /// ruteador, la orientación, Gemini al reinterpretar y Jev (pegada al
    /// pedido: ver `run`).
    private var task: String?
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
    private var challenge: Challenge? {
        didSet { if challenge != nil, oldValue == nil { onChallenge?() } }
    }
    private struct Challenge {
        enum Resume { case question(String), rest(String), look }
        let url: String
        let resume: Resume
        /// Una pregunta hecha con la prueba todavía en pantalla: se contesta
        /// después de lo que se retoma. "¿Cuánto sale el más barato?" frente
        /// a la prueba de Mercado Libre iba al modelo, que contestaba sobre
        /// la página de seguridad.
        var after: String?
        /// Lo que se puede buscar en otro sitio si la persona no la resuelve.
        var elsewhere: String?
    }
    /// Hay una prueba anti-robot esperando a la persona. Mientras tanto la
    /// página se vuelve a mirar sola: ver `ReaderModel.watchChallenge`.
    var waitsForChallenge: Bool { challenge != nil }
    /// Lo llama el asistente cuando aparece una prueba.
    var onChallenge: (() -> Void)?
    /// Sube cuando el cursor tiene que quedarse en la página —"Ir a la
    /// prueba"— y no volver a las opciones.
    private(set) var pageFocusRequests = 0
    /// Sube cuando el asistente tiene que volver a la vista: la prueba se
    /// resolvió con el asistente cerrado, y lo que sigue lo dice él.
    private(set) var panelRequests = 0
    /// Las opciones que había antes de "Otra cosa", para volver a ellas.
    private var stashed: Offer?
    static let restoreID = "jef-volver-a-las-opciones"
    /// Los titulares que se dijeron al llegar a una portada.
    private var leadSaid = 0
    /// Lo que ya se dijo de esta página —al llegar y al contestar—, para
    /// no repetirlo: el resumen repetía la presentación de la nota, y se
    /// ofrecía "¿Qué temperaturas se esperan?" después de decirlas.
    private var saidHere: (url: String, text: String) = ("", "")
    private func remember(_ text: String, on page: ExtractedPage) {
        saidHere = saidHere.url == page.url ? (page.url, saidHere.text + " " + text) : (page.url, text)
    }
    /// La tarea que se está siguiendo sola, para ofrecer buscarla en otro
    /// lado si una prueba anti-robot la corta.
    private var runningTask: String?
    static let solvedID = "jef-ya-resuelta"
    static let toTestID = "jef-ir-a-la-prueba"

    /// La dirección de la última página que se contó. Si la página cambia
    /// sola y queda en otra, hay que decirlo.
    private var knownURL: String?
    /// Lo que la orientación dijo de cada página: qué es y sus próximos
    /// pasos, en orden. Es el único lugar que decide qué se le ofrece a la
    /// persona en una página; después de leer o de contestar, se vuelve a
    /// ofrecer esto.
    private var known: [String: (kind: Answerer.Orientation.Kind, steps: [Action])] = [:]
    /// El formulario elegido como un solo paso —«Buscar en ANSES»—: cuando
    /// tiene todos sus datos, se envía.
    private var completing: Action?
    /// Jev buscando en la página mientras el ruteador decide: si decide
    /// abrir o buscar acá, la respuesta ya está. Iban en fila y el ruteador
    /// tarda un par de segundos; Jev, medio. Si decide otra cosa, se pierde
    /// una pregunta a Jev, que cuesta unas cuarenta veces menos. Se usa sólo
    /// con la misma página, el mismo pedido y los mismos elementos: su
    /// respuesta es una posición en esa lista.
    private var early: (url: String, request: String, ids: [String], answer: Task<PageAnalyzer.Found?, Never>)?
    /// El campo cuyo valor se le pidió a la persona: lo próximo que escriba
    /// va ahí. Ver `ask`.
    private var awaitingField: Action.Field? {
        didSet {
            awaiting = awaitingField.map(Self.spoken)
            awaitingSecret = awaitingField?.isSecure == true
        }
    }
    /// Si el dato que se espera es una contraseña: el campo de escribir la
    /// tapa, como cualquier campo de contraseña de iOS.
    private(set) var awaitingSecret = false
    /// El nombre del campo que espera su dato, para que el campo de escribir
    /// lo diga en vez de "¿Qué querés hacer?".
    private(set) var awaiting: String?
    /// Campos ya completados, para no volver a ofrecerlos.
    private var filledFields: Set<String> = []
    /// Las preguntas que siguen a una respuesta, como botones.
    private var nextQuestions: [String] = []
    /// Una pregunta que la página no contestó: se ofrece buscarla afuera.
    private var searchInstead: String?
    /// Primero la página: con un sitio abierto, lo pedido se busca en él, y
    /// sólo si no está, afuera (Daniel, 2026-09-22). False cuando la persona
    /// ya pidió buscarlo afuera con el botón.
    private var pageFirst = true

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
    /// Igual, pero sin mirar antes la página: "Buscarlo en internet" se
    /// ofrece porque en la página no estaba.
    static let outsidePrefix = "jef-afuera:"

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
    func ask(_ goal: String, on reader: ReaderModel, shown: String? = nil, outside: Bool = false) async {
        let goal = goal.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !goal.isEmpty, !working else { return }
        inTurn = true
        defer { inTurn = false }
        // Un dato para un campo —un DNI— se muestra tapado: la pantalla la
        // puede ver cualquiera al lado.
        // Un botón nunca es el dato: tocar "Completar «Apellido*»" mientras se
        // esperaba el nombre escribió "completá el campo Apellido*" en Nombre.
        // Con un campo pedido, lo que se escribe es el dato: para cambiar de
        // idea están los botones. Antes una lista de palabras en castellano
        // adivinaba si era un dato o un pedido nuevo.
        let secret = awaitingField?.isSecure == true && shown == nil
        let isValue = awaitingField != nil && shown == nil
        // Tapado y dicho en palabras: "•••••456" se leía como puntos. La
        // contraseña, sin ninguna letra.
        let name = awaitingField.map(Self.spoken) ?? "Dato"
        heard(secret ? "\(name) escrita" : isValue ? "\(name) terminado en \(goal.suffix(3))" : shown ?? goal)
        offer = nil
        touched = []
        lastDone = nil
        failedTurn = false
        pendingQuestion = nil
        nextQuestions = []
        searchInstead = nil
        pageFirst = !outside
        previousRequest = lastRequest
        lastRequest = goal
        defer { closeTurn(on: reader) }

        // Se preguntó "¿Qué pongo en DNI?" y esto es la respuesta: va directo
        // a ese campo de la página, sin pasar por el ruteador. Antes el
        // asistente no recordaba que estaba esperando un dato, y un DNI
        // suelto tenía que adivinarse de nuevo en la nube.
        if let field = awaitingField {
            awaitingField = nil
            if isValue {
                working = true
                reader.fill(field, with: goal)
                try? await Task.sleep(for: .milliseconds(700))
                working = false
                filledFields.insert(field.id)
                // Y no queda como "lo que pidió antes": eso viaja al modelo en
                // el turno siguiente, y un DNI no tiene que ir a ningún lado.
                lastRequest = previousRequest
                // Un formulario elegido como un paso: con todos sus datos, se
                // envía. Un buscador se busca; lo demás pasa por "¿compromete?".
                if let form = completing, (form.fields ?? []).contains(where: { $0.id == field.id }) {
                    completing = nil
                    let missing = (form.fields ?? []).filter {
                        $0.type != "hidden" && $0.type != "checkbox" && !Self.isChallenge($0) && !filledFields.contains($0.id)
                    }
                    if let next = missing.first {
                        awaitingField = next
                        completing = form
                        say("Listo. ¿Qué pongo en «\(Self.spoken(next))»?")
                        inputRequests += 1
                        return
                    }
                    if Self.isSearch(form) {
                        say("Buscando «\(Self.short(goal, 60))».")
                        working = true
                        await reader.submit(form)
                        working = false
                        await landed(reader)
                    } else {
                        await submitAsked(form, on: reader)
                    }
                    return
                }
                // Sin repetir el dato entero: un DNI dicho en voz alta en la
                // calle no. Las tres últimas cifras alcanzan para confirmarlo.
                say(field.isSecure
                    ? "Listo: quedó escrita en «\(Self.spoken(field))»."
                    : "Listo: quedó escrito en «\(Self.spoken(field))», terminado en \(goal.suffix(3)).")
                return
            }
        }
        completing = nil

        // Una dirección es una dirección. Buscarla adentro de la página —que
        // es lo que hacía— termina ofreciendo "¿querés que vaya a Inicio?"
        // cuando lo que se pidió fue google.com.
        if let url = ReaderModel.normalize(goal), goal.contains(".") , !goal.contains(" ") {
            // Escribir una dirección no declara otra tarea que estar ahí: con
            // «elcomercio.pe» como tarea, la orientación sugería «Lo último» y
            // «Debate» antes que los titulares.
            task = nil
            say("Abriendo \(Self.bare(Self.unicode(url.host() ?? "")) ?? goal).")
            working = true
            reader.address = goal
            await reader.go()
            working = false
            await landed(reader)
            return
        }

        // Una pregunta con la prueba anti-robot todavía en pantalla no va al
        // modelo: la página es la de seguridad, y lo que contestaba era "la
        // página actual es de seguridad". Se anota y se contesta después.
        // Escrita, no tocada: "Buscarlo en otro sitio" también lleva signos
        // de pregunta, y es justamente la salida.
        if var pending = challenge, shown == nil, let page = reader.page, Self.hasChallenge(page), Self.isQuestion(goal) {
            pending.after = goal
            challenge = pending
            lastRequest = previousRequest
            say("Todavía está la prueba anti-robot en la página. Cuando esté resuelta, contesto eso.")
            return
        }
        // Cualquier otro pedido deja la prueba atrás: se fue a otro lado.
        challenge = nil

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
        if router != nil {
            working = true
            early = nil
            if let page = reader.page, let analyzer {
                let request = jevRequest(goal)
                let options = openable(page)
                if !options.isEmpty {
                    early = (page.url, request, options.map(\.id),
                             Task { await analyzer.find(request, among: options, site: page.url) })
                }
            }
            let decision: Router.Decision?
            do { decision = try await decide(goal, on: reader, previous: previousRequest) }
            catch Router.RouterError.transport {
                working = false
                say("Sin conexión. No puedo entender lo que pedís sin internet.")
                return
            }
            catch {
                Registro.anotar("error", ["donde": "decidir", "detalle": String(describing: error)])
                decision = nil
            }
            working = false
            if decision?.newTask ?? true || task == nil { task = goal }

            if let decision {
                await carry(decision.action, of: decision, goal: goal, on: reader)
                // El segundo pedido de una frase que traía dos: "resumime y
                // después entrame a la de Milei". Descartarlo en silencio era
                // uno de los errores que la medición encontró. Si se quedó
                // esperando un dato, el segundo espera: enviar sin el dato no.
                if let next = decision.then, Self.chains(decision.action, next), !working, awaitingField == nil {
                    await carry(next, of: decision, goal: goal, on: reader)
                }
                // Y lo que falta de la tarea, ahora que ya hay otra página.
                // "Quiero entrar a ANSES y pedir un turno" aterrizaba en ANSES
                // y el turno se perdía: el pedido no sobrevivía al viaje.
                if let rest = decision.rest, !rest.isEmpty {
                    if offer?.options.contains(where: { $0.id.hasPrefix("res-") }) == true {
                        // Se frenó a preguntar cuál resultado. La tarea espera
                        // a que la persona elija; seguir ahora sería resolver
                        // "pedir un turno" contra la página del buscador.
                        waiting = rest
                        say("Cuando elijas, sigo con «\(rest)».")
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
        if router == nil { task = goal }
        guard reader.page != nil else {
            await arrive(goal, on: reader)
            return
        }
        await run(goal, on: reader, steps: Self.maxSteps)
    }

    /// Si el segundo pedido de una frase se hace a continuación del primero.
    /// Dos navegaciones seguidas no: "ir" a Mercado Libre y después "buscar"
    /// con el mismo destino buscaba dos veces lo mismo, y la persona oía
    /// "Buscando: mercado libre" dos veces. Lo que falta de la tarea va en
    /// `rest`, que se decide de nuevo en la otra página.
    static func chains(_ action: Router.Action, _ next: Router.Action) -> Bool {
        let moves: Set<Router.Action> = [.ir, .buscar, .abrir, .volver]
        return !(moves.contains(action) && moves.contains(next))
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
        guard router != nil else { return }
        runningTask = rest
        defer { runningTask = nil }
        var goal = rest
        for _ in 0..<Self.maxHops {
            guard reader.page != nil else { return }
            // Sin anunciar "Sigo con: buscame…": cada paso ya dice lo que hace
            // ("Buscando auriculares en…"), y la orden de la persona repetida
            // tal cual sonaba a que JEF le daba órdenes.
            working = true
            let decision = try? await decide(goal, on: reader)
            working = false
            guard let decision else { return }
            await carry(decision.action, of: decision, goal: goal, on: reader)
            // El segundo pedido de la frase, como en `ask`: "completar" y
            // "enviar" es buscar con el buscador del sitio, y acá se perdía —
            // en Mercado Libre quedaba escrito y sin buscar.
            if let next = decision.then, Self.chains(decision.action, next), !working, awaitingField == nil {
                await carry(next, of: decision, goal: goal, on: reader)
            }
            guard let more = decision.rest, !more.isEmpty, more != goal else { return }
            goal = more
        }
    }

    /// Un campo o un botón de formulario, como se le numera al modelo.
    struct FormControl {
        let label: String
        let form: Action
        let field: Action.Field?
    }

    /// Los campos y botones de todos los formularios de la página, en orden.
    static func formControls(_ page: ExtractedPage) -> [FormControl] {
        var out: [FormControl] = []
        for form in page.actions where form.kind == .form && !(form.fields ?? []).isEmpty {
            for field in (form.fields ?? []) where field.type != "hidden" {
                let name = spoken(field) + (field.isSecure ? " (secreto)" : "")
                out.append(FormControl(label: "campo «\(name)»", form: form, field: field))
            }
            if let button = form.submit?.trimmingCharacters(in: .whitespacesAndNewlines), !button.isEmpty {
                out.append(FormControl(label: "botón «\(button)»", form: form, field: nil))
            }
        }
        return out
    }

    /// Los de la última decisión: `control` es un número de esta lista.
    private var controls: [FormControl] = []

    private func control(_ decision: Router.Decision) -> FormControl? {
        guard let number = decision.control, controls.indices.contains(number - 1) else { return nil }
        return controls[number - 1]
    }

    /// Lo que decide el modelo, con todo a la vista: la página con su texto,
    /// sus campos y botones numerados, dónde está la persona y lo que pidió
    /// antes. Las reglas van en `decisiones.json`.
    private func decide(_ goal: String, on reader: ReaderModel, previous: String? = nil) async throws -> Router.Decision? {
        guard let router else { return nil }
        let page = reader.page
        let state = Router.state(page: page, reading: readingProgress(page), previous: previous)
        controls = page.map(Self.formControls) ?? []
        let decision = try await router.decide(
            goal, task: task == goal ? nil : task, state: state, place: Ubicacion.shared.place,
            page: page.map(Self.saying), controls: controls.map(\.label)
        )
        // Sin el valor: un DNI dictado no va al registro.
        Registro.anotar("decision", [
            "accion": decision.action.rawValue, "target": decision.target ?? "", "reference": decision.reference ?? "",
            "question": decision.question ?? "", "control": decision.control.map(String.init) ?? "",
            "then": decision.then?.rawValue ?? "", "rest": decision.rest ?? "",
            "tarea": decision.newTask ? "nueva" : "sigue",
        ])
        return decision
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
            await arrive(decision.target ?? goal, on: reader)

        case .buscar:
            // Primero la página (Daniel, 2026-09-22): con un sitio abierto, lo
            // pedido se busca en él —un dato, en lo que dice; un lugar, entre
            // lo que se puede tocar— y sólo si no está, afuera. La página del
            // buscador no es un sitio: ahí buscar es buscar de nuevo.
            let query = decision.target ?? goal
            // También en la página del buscador: sus resultados son lo que hay
            // ahí. «Sacar turno» en los resultados de ANSES terminó en
            // "Buscando: https://www.anses.gob.ar".
            if pageFirst, let page = reader.page {
                // Un dato, primero en lo que la página dice.
                if decision.question != nil {
                    working = true
                    let missing = await reply(goal, about: page, quiet: true)
                    working = false
                    if !missing { return }
                }
                // Después, entre lo que se puede tocar, como "abrir": Jev, y si
                // duda, Gemini. "Quiero cobrar por mi hijo" en ANSES era un
                // dato para el ruteador, la página no lo decía en su texto, y
                // salía a Google con la Asignación Universal por Hijo ahí.
                await run(goal, on: reader, steps: Self.maxSteps, said: goal, orElse: query, question: decision.question)
                return
            }
            // Si salió de una pregunta, se contesta en el sitio que elija.
            if let question = decision.question { pendingQuestion = question }
            await arrive(query, on: reader)

        case .abrir:
            // Una referencia —"la segunda", "el del paro"— se resuelve contra
            // lo que la página ofrece de verdad. El modelo nombra; la lista
            // de destinos la pone la página, nunca él.
            await run(decision.reference ?? goal, on: reader, steps: Self.maxSteps, said: goal)

        case .leer:
            guard let page = reader.page else { return }
            readingFrom = 0
            readAloud(page)

        case .seguir:
            guard let page = reader.page else { return }
            readAloud(page)

        case .resumir:
            guard let page = reader.page else { return }
            working = true
            await summarize(page)
            working = false

        case .responder:
            guard let page = reader.page else { return }
            working = true
            // Con las palabras de la persona, no con las del ruteador. Una vez
            // reescribió "¿y el oficial?" como "¿cuándo se fundó…?" —un
            // ejemplo de sus propias instrucciones— y eso fue lo contestado.
            // El contexto de la pregunta anterior ya viaja aparte. Y por dónde
            // va la lectura, que no está en la página: "¿cuánto falta?".
            await reply(goal, about: page, reading: readingProgress(page).map { "at block \($0.at) of \($0.of)" })
            working = false

        case .completar:
            // El ruteador pidió escribir y la página no tiene dónde. Si es una
            // tarea que viene de otra página —"entrá a Mercado Libre y buscame
            // auriculares" llegó al selector de país—, se cuenta la página, que
            // pregunta lo que falta con sus opciones como botones, y la tarea
            // espera a que la persona elija. Si no, se busca lo pedido, primero
            // en la página. Antes: "Acá no hay un formulario para completar".
            if controls.isEmpty, let page = reader.page {
                if runningTask != nil {
                    waiting = goal
                    working = false
                    // Una sola vez: si la página ya se contó al llegar, con su
                    // pregunta y sus botones, no se cuenta de nuevo.
                    if knownURL != page.url || offer == nil { await arrived(page) }
                    if offer != nil { say("Cuando elijas, sigo con «\(Self.short(goal, 60))».") }
                    return
                }
                let search = Router.Decision(
                    action: .buscar, target: decision.value ?? decision.target, reference: nil, question: nil,
                    control: nil, value: nil, then: nil, rest: nil, message: nil)
                await carry(.buscar, of: search, goal: goal, on: reader)
                return
            }
            await complete(decision, goal: goal, on: reader)

        case .enviar:
            // El "enviar" que seguía a un "completar" sin formulario: ya se
            // resolvió arriba, y "Acá no hay un formulario para enviar" se
            // decía de más.
            if decision.action == .completar, controls.isEmpty { return }
            guard let page = reader.page,
                  let form = control(decision)?.form ?? pageForm(page)
            else { say("Acá no hay un formulario para enviar."); return }
            await submitAsked(form, on: reader)

        case .volver:
            await goBack(on: reader)

        case .orientar:
            guard let page = reader.page else {
                say("Puedo abrir sitios, buscar, leer páginas, resumirlas y contestar lo que dicen. Para empezar, se puede escribir un sitio o algo para buscar, o tocar una de estas opciones.")
                offer = Offer(goal: "", options: Self.starters)
                return
            }
            // Corto: dónde, y qué es esto. Contar la portada entera otra vez
            // no contestaba "no entiendo, ¿dónde estoy?".
            // Con el nombre corriente del lugar ("la portada de La Nación") y
            // en primera persona: "la conversación con JEF: se le pide algo"
            // sonaba a que JEF era otro.
            let gestures = UIAccessibility.isVoiceOverRunning
                ? " Las opciones vienen después de este mensaje: deslizando a la derecha se llega a ellas."
                : ""
            say("Estás en \(whereIs(page)). Arriba se ve la página, y esto es la conversación conmigo, JEF: se avanza tocando una opción o escribiendo lo que haga falta.\(gestures)")

        case .noPuedo:
            say(decision.message ?? "Eso no lo sé hacer.")
        }
    }

    /// Escribir en el campo que eligió el modelo, por su número en la lista
    /// de formulario: el número tiene que existir, y el campo es el de la
    /// página. Sin número, se ofrecen los campos como botones.
    private func complete(_ decision: Router.Decision, goal: String, on reader: ReaderModel) async {
        guard let page = reader.page else { return }
        guard !controls.isEmpty else { say("Acá no hay un formulario para completar."); return }
        guard let field = control(decision)?.field else {
            say("¿En qué campo lo escribo?")
            return
        }
        // Un desafío de imagen no se completa por más que sea un campo de
        // texto: el código está dibujado y nadie de este lado lo ve.
        if Self.isChallenge(field) {
            askToSolve(page, image: true)
            return
        }
        // El valor tiene que estar en lo que dijo la persona: el modelo que lo
        // propone ve la página, y una página no puede dictar qué se escribe.
        // Si no está —o lo transformó—, se le pregunta en vez de escribirlo.
        guard let value = decision.value, !value.isEmpty, personSaid(value, goal: goal) else {
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
        say(field.isSecure ? "Listo: quedó escrita en «\(Self.spoken(field))»." : "Listo, escrito en \(Self.spoken(field)).")
    }

    // MARK: - Llegar a algún lado desde la nada

    /// Un resultado de buscador del que podemos probar que es un resultado.
    struct Result: Sendable {
        let title: String
        let href: String
        /// El sitio, cuando el link no lo dice: Google pasa por un salto
        /// suyo y el sitio viene escrito en el resultado.
        var site: String? = nil
        /// Lo que el buscador muestra justo antes y justo después: donde dice
        /// si es un anuncio, en su idioma. Para Jev, no para el código.
        var before = ""
        var after = ""
        /// Como se escribe, no como viaja: "tiempomañana.net" y no
        /// "xn--tiempomaana-8db.net", que es lo que se leía en voz alta.
        var host: String { site ?? Assistant.unicode(URL(string: href)?.host()?.lowercased() ?? "") }
    }

    /// Un dominio internacional con sus letras: cada parte "xn--…" se
    /// decodifica (Punycode, RFC 3492). Si algo no cierra, queda como vino.
    nonisolated static func unicode(_ host: String) -> String {
        host.split(separator: ".", omittingEmptySubsequences: false).map { part in
            guard part.hasPrefix("xn--"), let decoded = punycode(String(part.dropFirst(4))) else { return String(part) }
            return decoded
        }.joined(separator: ".")
    }

    nonisolated private static func punycode(_ input: String) -> String? {
        let base = 36, tmin = 1, tmax = 26, skew = 38, damp = 700
        func adapt(_ delta: Int, _ points: Int, _ first: Bool) -> Int {
            var delta = first ? delta / damp : delta / 2
            delta += delta / points
            var k = 0
            while delta > ((base - tmin) * tmax) / 2 { delta /= base - tmin; k += base }
            return k + ((base - tmin + 1) * delta) / (delta + skew)
        }
        func digit(_ c: Character) -> Int? {
            guard let v = c.asciiValue else { return nil }
            switch v {
            case 48...57: return Int(v) - 22     // 0-9 → 26-35
            case 97...122: return Int(v) - 97    // a-z → 0-25
            case 65...90: return Int(v) - 65
            default: return nil
            }
        }
        let chars = Array(input)
        var output: [Unicode.Scalar] = []
        var start = 0
        if let dash = chars.lastIndex(of: "-") {
            for c in chars[..<dash] { guard let s = c.unicodeScalars.first, s.isASCII else { return nil }; output.append(s) }
            start = dash + 1
        }
        var n = 128, i = 0, bias = 72, pos = start
        while pos < chars.count {
            let old = i
            var w = 1, k = base
            while true {
                guard pos < chars.count, let d = digit(chars[pos]) else { return nil }
                pos += 1
                i += d * w
                let t = k <= bias ? tmin : (k >= bias + tmax ? tmax : k - bias)
                if d < t { break }
                w *= base - t
                k += base
            }
            bias = adapt(i - old, output.count + 1, old == 0)
            n += i / (output.count + 1)
            i %= output.count + 1
            guard let scalar = Unicode.Scalar(n) else { return nil }
            output.insert(scalar, at: i)
            i += 1
        }
        return String(String.UnicodeScalarView(output))
    }

    /// Adónde ir cuando todavía no hay página.
    ///
    /// El orden es por costo y por certeza, no por elegancia: una dirección
    /// se carga, y todo lo demás se busca. Lo que NO se hace es pedirle a un
    /// modelo que adivine un dominio — inventar "lanacion.com.ar" es fácil,
    /// inventar "bancoprovinciadesantafe.com.ar" es cómo se manda a alguien
    /// que no ve a un sitio que no es el suyo.
    private func arrive(_ goal: String, on reader: ReaderModel) async {
        working = true
        defer { working = false }
        // Con las tildes de la persona: el ruteador devolvía "clarin" y se
        // oía "Buscando: clarin" después de haber escrito "clarín".
        var goal = Self.inTheirWords(goal, from: lastRequest)

        // Una dirección no se adivina: la escribió la persona. Si la escribió
        // el ruteador —"buscá mar del plata en wikipedia" volvió una vez como
        // ir a "wikipedia.org"—, no se carga: se busca. Cargada, llevó al
        // portal en inglés con un pedido de donaciones.
        let typed = (lastRequest ?? "").lowercased().contains(goal.lowercased().replacingOccurrences(of: "www.", with: ""))
        if typed, let url = ReaderModel.normalize(goal), goal.contains("."), !goal.contains(" ") {
            say("Abriendo \(Self.bare(Self.unicode(url.host() ?? "")) ?? goal).")
            reader.address = goal
            await reader.go()
            await landed(reader)
            return
        }

        // Y si es una dirección que escribió el ruteador, se busca el sitio,
        // sin "https://www.": se decía "Buscando: https://www.anses.gob.ar".
        goal = URL(string: goal).flatMap { url in
            url.scheme.map { ["http", "https"].contains($0) } == true ? url.host().flatMap(Self.bare) : nil
        } ?? goal
        say("Buscando: \(goal).")
        reader.address = Self.searchURL(for: goal)
        await reader.go()
        // Lo que cargó no es la página de resultados: el buscador pidió
        // comprobar que no es un robot ("tráfico inusual"). Se cuenta lo que
        // hay, como cualquier llegada; "No encontré resultados" decía que no
        // existían.
        if let page = reader.page, Self.searchQuery(of: page) == nil {
            await landed(reader)
            return
        }
        var (found, ads): ([Result], Int) = ([], 0)
        if let page = reader.page { (found, ads) = await organic(page) }
        guard !found.isEmpty else {
            // Pasa de verdad: en una consulta comercial la página trae
            // resultados y nosotros extraemos cero. Decirlo es mejor que
            // abrir cualquier cosa.
            say("No encontré resultados para «\(goal)».")
            failedTurn = true
            return
        }

        // Si el pedido era una pregunta y la página del buscador ya la
        // contesta —Google trae el pronóstico arriba de todo—, se contesta
        // ahí, y los resultados quedan como botones para ir a la fuente. Lo
        // decide el modelo: si la página no alcanza, no contesta.
        if let question = pendingQuestion, let answerer, let page = reader.page,
           let answer = try? await answerer.answer(question, about: Self.saying(page), previous: previousRequest) {
            pendingQuestion = nil
            knownURL = page.url
            say(answer.text)
            remember(answer.text, on: page)
            present(found, for: goal, speak: false)
            return
        }

        // Y acá no se elige. Se presenta, sin los anuncios.
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
        // Y en el orden del buscador, sin reordenar: medido contra 162
        // búsquedas reales de sitios con dueño conocido, el primero de
        // DuckDuckGo era el correcto en el 98 % y el correcto estaba entre
        // los tres primeros en todas. Las reglas propias que lo reordenaban
        // —país, "lo oficial primero", coincidencias— lo empeoraban: en un
        // iPhone con región Estados Unidos subieron una copia de la banca
        // del Banco Nación alojada en vercel.app por encima del banco. Lo
        // decidió Daniel (2026-09-21): el orden es el del buscador, y la
        // persona elige entre los tres primeros.
        present(found, for: goal, ads: ads)
    }

    /// Los resultados del buscador sin los anuncios, en el orden del
    /// buscador, y cuántos anuncios se sacaron.
    ///
    /// Jev juzga cada resultado (ver `PageAnalyzer.adProbabilities`); lo que
    /// da anuncio por encima del umbral de `criterios.json` no se ofrece como
    /// botón, pero se cuenta: filtrar no es esconder. Los orgánicos no se
    /// juzgan: si Google pone primero a un intermediario, ese es el
    /// resultado (Daniel). Si Jev no contesta a tiempo, van todos.
    private func organic(_ page: ExtractedPage) async -> (results: [Result], ads: Int) {
        if organicCache.url == page.url { return (organicCache.results, organicCache.ads) }
        let found = Self.results(of: page)
        if found.isEmpty { Self.noteMissing(page) }
        guard let analyzer, !found.isEmpty else { return (found, 0) }
        let limit = Criterios.actuales?.umbrales["anuncio"] ?? 1
        guard let judged = await analyzer.adProbabilities(
            found.map { (result: "\($0.title) — \($0.host)", before: $0.before, after: $0.after) })
        else { return (found, 0) }
        let ads = found.indices.filter { (judged[$0] ?? 0) >= limit }
        Registro.anotar("anuncios", ["url": page.url, "sacados": ads.map { found[$0].host }])
        let kept = found.indices.filter { !ads.contains($0) }.map { found[$0] }
        organicCache = (page.url, kept, ads.count)
        return (kept, ads.count)
    }

    /// Una página del buscador de la que no salió ningún resultado: qué vio
    /// el extractor, al registro. Google cambia su formato según la búsqueda
    /// —"Resultado web con vínculos a sitio" llegó sin la dirección de cada
    /// sitio— y sin esto no había cómo saber qué traía.
    private static func noteMissing(_ page: ExtractedPage) {
        let cards = page.listings.flatMap(\.items).prefix(12).map { item in
            "\(item.title) | \(String((item.meta ?? "").prefix(90))) | \(String((item.href ?? "").prefix(60)))"
        }
        let links = (page.stream ?? []).filter { $0.kind == "link" }.prefix(12).map { entry in
            "\(String((entry.label ?? "").prefix(90))) | \(String((entry.href ?? "").prefix(60)))"
        }
        Registro.anotar("sin-resultados", ["url": page.url, "tarjetas": Array(cards), "links": Array(links)])
    }

    /// Los de la última página de resultados: volver a ella no vuelve a
    /// preguntar.
    private var organicCache: (url: String, results: [Result], ads: Int) = ("", [], 0)

    /// Lo que se encontró, como botones.
    ///
    /// De a tres, porque tres opciones se retienen de memoria y diez no —y
    /// quien no ve tiene que retenerlas de memoria, no puede barrerlas con la
    /// vista—. El resto queda detrás de "Ver más opciones", que también es un
    /// botón.
    /// `speak`: decirlos. Al volver a una lista ya escuchada, no: la persona
    /// ya los oyó, y releerlos era medio minuto de lo mismo.
    private func present(_ results: [Result], for goal: String, speak: Bool = true, ads: Int = 0) {
        pending = Array(results.dropFirst(Self.shownAtOnce))
        let shown = results.prefix(Self.shownAtOnce)
        // Cada resultado aparece una sola vez: como el botón que se toca,
        // justo debajo de esto. Escritos además como mensajes quedaban
        // repetidos, y los botones lejos del texto que los presentaba.
        // En voz alta sí se dicen, porque quien no ve no los barre con la
        // vista.
        // Sin contar el total: contaba sitios y no resultados, y no
        // coincidía con lo que se ve en la página.
        let skipped = ads == 0 ? "" : ads == 1 ? " Hay un anuncio: lo salteo." : " Hay \(ads) anuncios: los salteo."
        let found = "Estás en los resultados de «\(goal)».\(skipped)"
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
        /// El país: el de donde está la persona. Ver `Ubicacion`.
        @MainActor
        func url(for query: String) -> String {
            let escaped = query.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? query
            var country = (Ubicacion.countryForSearch ?? "US").lowercased()
            // DuckDuckGo le dice "uk" al Reino Unido.
            if self == .duckduckgo, country == "gb" { country = "uk" }
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

    /// Se puede cambiar sin compilar, para probar: `defaults write
    /// ai.jef.browser buscador google`.
    static var engine: Engine = UserDefaults.standard.string(forKey: "buscador").flatMap(Engine.init(rawValue:)) ?? .google

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
        var found: [(title: String, href: String)] = []
        var context: [(before: String, after: String)] = []
        var shown: [String?] = []
        let byID = Dictionary(page.listings.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let actions = Dictionary(page.actions.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let stream = page.stream ?? []
        // Lo que dice cada parada del recorrido, para darle a cada resultado
        // lo que tiene al lado.
        func text(_ index: Int) -> String {
            guard stream.indices.contains(index) else { return "" }
            let entry = stream[index]
            let said = entry.block?.plainText ?? entry.label ?? entry.ref.flatMap { actions[$0]?.label ?? byID[$0]?.title } ?? ""
            return String(said.prefix(120))
        }
        for (index, entry) in stream.enumerated() {
            let around = (before: text(index - 1), after: text(index + 1))
            switch entry.kind {
            case "link":
                if let label = entry.label, let href = entry.href { found.append((label, href)); context.append(around); shown.append(nil) }
            case "listing":
                guard let listing = entry.ref.flatMap({ byID[$0] }) else { continue }
                for item in listing.items {
                    if let href = item.href { found.append((item.title, href)); context.append(around); shown.append(item.shown) }
                }
            default: continue
            }
        }
        return results(from: found, context: context, shown: shown)
    }

    /// Los resultados de verdad entre los links de una página de buscador,
    /// en su orden. Aparte de la página para poder probarla contra búsquedas
    /// guardadas: ver Tests/buscador.
    /// `shown`: la dirección que muestra cada link, si la extrajo la página
    /// aparte del título (ver `Listing.Item.shown`).
    static func results(from links: [(title: String, href: String)], context: [(before: String, after: String)] = [], shown: [String?] = []) -> [Result] {
        var out: [Result] = []
        var seen = Set<String>()

        func consider(_ title: String, _ href: String, shown: String? = nil) {
            // Los anuncios se sacan por el href, que es donde se declaran.
            let ad = "aclk\\?|googleadservices|doubleclick|/aclick|bing\\.com/aclick|duckduckgo\\.com/y\\.js|utm_medium=cpc"
            guard href.range(of: ad, options: [.regularExpression, .caseInsensitive]) == nil else { return }
            guard let url = URL(string: href), var host = url.host()?.lowercased() else { return }
            var title = title
            var site: String?
            // Google no da la dirección del resultado: da un salto suyo
            // (/goto, /url) y escribe el sitio al final del título: "Título,
            // AccuWeather, https://www.accuweather.com". Sin esto se tiraban
            // todos, por ser links de Google.
            // Y no siempre en el mismo orden: también "Bank of America,
            // https://www.bankofamerica.com, Bank of America".
            if host.contains("google."), ["/goto", "/url"].contains(url.path),
               let match = title.firstMatch(of: /https?:\/\/[^\s,›]+/),
               let shown = URL(string: String(match.output))?.host()?.lowercased() {
                var before = String(title[..<match.range.lowerBound])
                    .trimmingCharacters(in: CharacterSet(charactersIn: ", "))
                let after = title[match.range.upperBound...].trimmingCharacters(in: .whitespaces)
                // Con la dirección al final, lo que la precede es el sitio.
                if after.isEmpty || after.hasPrefix("›"), let comma = before.range(of: ", ", options: .backwards) {
                    before = String(before[..<comma.lowerBound])
                }
                title = before
                host = shown
                site = Assistant.unicode(shown)
            } else if host.contains("google."), ["/goto", "/url"].contains(url.path),
                      let shown, let target = URL(string: shown)?.host()?.lowercased() {
                // La dirección no está en el título sino aparte: el título de
                // la tarjeta es el de la nota, y la dirección, la que el link
                // muestra. Pasó con "Resultado web con vínculos a sitio".
                host = target
                site = Assistant.unicode(target)
            }
            // El buscador no es un resultado de sí mismo.
            let engine = "google\\.|gstatic|googleusercontent|bing\\.|microsoft\\.|duckduckgo\\.|brave\\.|startpage\\."
            guard host.range(of: engine, options: [.regularExpression]) == nil else { return }
            let clean = title.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !clean.isEmpty else { return }
            // La misma página dos veces —"eltrece en VIVO" con y sin
            // ?outputType=amp— es un resultado. Nada más se saca: ni se
            // reordena ni se descarta por país, por sitio o por nombre.
            guard seen.insert(flatten(clean) + "|" + host).inserted else { return }
            out.append(Result(title: clean, href: href, site: site))
        }

        // En Google, los resultados son los que pasan por su salto; los
        // links directos son botones del mapa ("Sitio web") o del recuadro
        // de la empresa, y se colaban antes que el primer resultado.
        func viaGoogle(_ href: String) -> Bool {
            guard let url = URL(string: href), let host = url.host()?.lowercased() else { return false }
            return host.contains("google.") && ["/goto", "/url"].contains(url.path)
        }
        let results = links.filter { viaGoogle($0.href) }
        for (index, link) in links.enumerated() where results.isEmpty || viaGoogle(link.href) {
            let before = out.count
            consider(link.title, link.href, shown: shown.indices.contains(index) ? shown[index] : nil)
            // Lo que el buscador muestra alrededor: para saber si es un anuncio.
            if out.count > before, context.indices.contains(index) {
                out[out.count - 1].before = context[index].before
                out[out.count - 1].after = context[index].after
            }
        }
        return out
    }

    /// Lo que se escribe, dicho para el oído: "$1.550,00" es "$1.550". Con
    /// la voz rápida, los centavos en cero se oían "coma cero cero".
    static func forEar(_ text: String) -> String {
        text.replacingOccurrences(of: "(\\d),00(?!\\d)", with: "$1", options: .regularExpression)
    }

    /// Un título que entra en un botón, cortado en una palabra y no en la
    /// mitad: "…su evolución patrimo" era un botón que nadie entendía.
    /// Cien letras: con setenta, "Una jueza declaró la inconstitucionalidad de
    /// la ley que bajó la…" no decía qué ley.
    static func short(_ raw: String, _ limit: Int = 100) -> String {
        // Sin las comas de celdas vacías: "Solicitud de Jubilación, , ver
        // sub-trámites".
        // Ni el "ver sub-trámites" que ANSES le pega a cada trámite: es
        // cómo se abre, no qué es.
        let text = raw.replacingOccurrences(of: "(,\\s*)+,", with: ",", options: .regularExpression)
            .replacingOccurrences(of: "\\s{2,}", with: " ", options: .regularExpression)
            .replacingOccurrences(of: ",\\s*ver sub-?tr[aá]mites", with: "",
                                  options: [.regularExpression, .caseInsensitive])
            .replacingOccurrences(of: ",\\s*ver (m[aá]s|detalles?)\\s*$", with: "",
                                  options: [.regularExpression, .caseInsensitive])
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
        // Nunca lo que el campo tiene escrito: ese nombre viaja al modelo y al
        // registro, y lo escrito puede ser un DNI, un correo o una tarjeta.
        switch field.type {
        case "email":    return "correo"
        case "tel":      return "teléfono"
        case "password": return "contraseña"
        case "search":   return "búsqueda"
        default:         return "un campo sin nombre"
        }
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
        challenge = Challenge(url: page.url, resume: resume, elsewhere: runningTask)
        // Corta lo que se esté diciendo: en Mercado Libre el aviso quedó en
        // cola detrás de la descripción de la portada, y nunca llegó a tiempo.
        interruptNext = true
        // Quién la resuelve, dicho sin vueltas: "me pide resolver" hacía
        // creer que la iba a resolver JEF. Y qué pasa después, con las
        // palabras de la persona. Todo en un solo anuncio: el de la opción de
        // audio, aparte, lo cortaba el siguiente.
        let then: String
        switch resume {
        case .question(let question): then = "contesto «\(question)»"
        case .rest(let rest): then = "sigo con «\(rest)»"
        case .look: then = "seguimos"
        }
        if image {
            say("El sitio web pide copiar un código dibujado en una imagen, y eso no lo puedo hacer yo: hace falta resolverlo en la página. Cuando esté resuelto, \(then).")
        } else {
            let audio = page.overlay?.audioChallenge == true ? ", y tiene opción de audio" : ""
            say("El sitio web pide resolver una prueba anti-robot, y esa prueba no la puedo resolver yo: hace falta resolverla en la página. «Ir a la prueba» lleva hasta ella\(audio). Cuando esté resuelta, \(then).")
        }
    }

    /// Si la página todavía pide la prueba.
    static func hasChallenge(_ page: ExtractedPage) -> Bool {
        page.overlay?.kind == .captcha || page.actions.contains {
            $0.kind == .form && ($0.fields ?? []).contains(where: isChallenge)
        }
    }

    /// Lo que se estaba haciendo cuando apareció la prueba.
    private func resume(_ task: Challenge, on reader: ReaderModel) async {
        guard let page = reader.page else { return }
        switch task.resume {
        case .question(let question):
            working = true
            await reply(question, about: page)
            working = false
        case .rest(let rest):
            await continueWith(rest, on: reader)
        case .look:
            // Con una pregunta esperando, la pregunta es lo que se quiere
            // saber: describir la página antes era hacerla esperar.
            if task.after == nil { await arrived(page) }
        }
        if let question = task.after, let page = reader.page, !Self.hasChallenge(page) {
            working = true
            await reply(question, about: page)
            working = false
        }
    }

    /// Las preguntas sugeridas que no son la que se acaba de contestar: después
    /// de "¿y el oficial?", ofrecer "¿Y el dólar oficial?" era repetirla. Que
    /// no repita lo que la respuesta ya contestó lo pide el prompt; acá se
    /// comparaban raíces de cinco letras, que sólo andaban en castellano.
    static func fresh(_ questions: [String], after asked: String) -> [String] {
        questions.filter { flatten($0) != flatten(asked) }
    }

    /// Una dirección sin consulta ni fragmento: el lugar, no el estado.
    static func place(_ address: String) -> String {
        guard var parts = URLComponents(string: address) else { return address }
        parts.query = nil
        parts.fragment = nil
        return parts.string ?? address
    }

    /// La opción que se llama exactamente como lo pedido, sin artículos ni
    /// verbos de ir: "llevame a deportes" → "Deportes".
    static func exactOption(for goal: String, among options: [Action]) -> Action? {
        let filler = "^(llevame|lleva|abri|abrime|abrir|anda|ir|quiero ir|mostrame|ver|entra)( a| al| a la| a los| a las)?\\s+"
        let asked = flatten(goal.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
            .replacingOccurrences(of: filler, with: "", options: .regularExpression)
            .replacingOccurrences(of: "^(la|el|los|las)\\s+", with: "", options: .regularExpression))
        guard asked.count >= 4 else { return nil }
        return options.first { flatten($0.label) == asked && $0.kind != .form }
    }

    /// Un dato tapado salvo sus tres últimos caracteres: "•••••456".
    static func masked(_ value: String) -> String {
        let visible = 3
        guard value.count > visible else { return String(repeating: "•", count: value.count) }
        return String(repeating: "•", count: value.count - visible) + value.suffix(visible)
    }

    /// Si lo escrito es una pregunta: por sus signos, en cualquier escritura.
    /// Antes, además, por cómo empezaba en castellano ("qué", "cuánto"…).
    static func isQuestion(_ text: String) -> Bool {
        text.contains { "?¿？؟".contains($0) }
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
            return Self.headlines(of: page).enumerated().map { "\($0.offset + 1). \(Self.dekick($0.element))" }
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

    /// Si en esta página se leen los titulares y no el texto: el modelo dijo
    /// que es una portada, y hay titulares. Antes lo decidía un piso de ocho
    /// titulares.
    private func readsHeadlines(_ page: ExtractedPage) -> Bool {
        known[page.url]?.kind == .portada && !Self.headlines(of: page).isEmpty
    }

    /// Una nota para leer: lo dijo el modelo al llegar. Antes eran dos
    /// párrafos de 160 letras, salvo quince titulares con menos de seis.
    private func isArticle(_ page: ExtractedPage) -> Bool {
        known[page.url]?.kind == .nota
    }

    /// Cómo se cuenta lo que se lee.
    private func readingUnit(_ page: ExtractedPage) -> String {
        readsHeadlines(page) ? "Titular" : "Párrafo"
    }

    private func readAloud(_ page: ExtractedPage) {
        if page.url != readingURL { readingURL = page.url; readingFrom = 0 }
        let pieces = readablePieces(page)
        let end = readsHeadlines(page) ? "Fin de los titulares." : isArticle(page) ? "Fin \(Self.of(page))." : "Fin de la página."

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
        if unit == "Titular" {
            // Sin el total —"de 143" contaba lo que el sitio repite— y
            // diciendo por qué no empieza en el 1: "Titulares 5 a 7" sin más
            // sonaba a que se habían perdido cuatro.
            let skipped = first == leadSaid + 1 && leadSaid > 0 ? "Los \(leadSaid) primeros ya los dije. " : ""
            say(first == last ? "\(skipped)Titular \(first):" : "\(skipped)Titulares \(first) a \(last):")
        } else {
            say(first == last
                ? "\(unit) \(first) de \(pieces.count):"
                : "Párrafos \(first) a \(last) de \(pieces.count):")
        }
        // Enteros: cortado a 600 letras, un párrafo largo terminaba en la
        // mitad de una palabra.
        for piece in chunk { say(piece) }
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
                    say("\(index + 1). \(Self.dekick(title))")
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
            say(Self.opening(opening, 400))
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
            // Sin repetir la presentación: al llegar a una nota ya se dijo de
            // qué trata, y el resumen era lo mismo con otras palabras.
            // Lo que ya escuchó de esta página va como dato del prompt
            // "resumir", no como una frase agregada a un pedido.
            let heard = saidHere.url == page.url && !saidHere.text.isEmpty ? saidHere.text : nil
            guard let answer = try await answerer.summary(of: text, alreadySaid: heard) else {
                readTheOpening()
                return
            }
            // Diciendo de qué: "resumime la nota" con la nota sin abrir
            // resumía la portada, y nadie se enteraba de que era la portada.
            // Qué se resume, sin repetir el título entero, que ya se escuchó
            // al llegar: "resumime la nota" con la nota sin abrir resumía la
            // portada sin decirlo.
            let what = readsHeadlines(page) ? "la portada" : isArticle(page) ? Self.the(page) : "la página"
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
        if action.id.hasPrefix(Self.outsidePrefix) {
            offer = nil
            await ask(String(action.id.dropFirst(Self.outsidePrefix.count)), on: reader, shown: action.label, outside: true)
            return
        }
        offer = nil
        completing = nil
        inTurn = true
        defer { inTurn = false }
        heard(action.label)
        lastDone = nil
        failedTurn = false
        nextQuestions = []
        searchInstead = nil
        working = true
        defer { working = false }

        // Lo que no es la prueba la deja atrás: se fue a otro lado.
        if ![Self.toTestID, Self.solvedID, Self.otherID, Self.restoreID].contains(action.id) {
            challenge = nil
        }

        // "Otra cosa": ninguna de las opciones era. Se pregunta y se deja a
        // la persona escribiendo, con un solo botón: volver a las opciones
        // de antes. Sin ninguno, quien se arrepentía tenía que escribir.
        if action.id == Self.otherID {
            say("¿Qué otra cosa hacemos? Se puede escribir, o dictar con el micrófono del teclado.")
            inputRequests += 1
            let before = chosen.options.filter { $0.id != Self.otherID }
            if !before.isEmpty {
                stashed = Offer(goal: chosen.goal, options: before)
                offer = Offer(goal: "", options: [.link(id: Self.restoreID, label: "Volver a las opciones", href: "", region: "main")])
            }
            return
        }
        defer { closeTurn(on: reader) }

        if action.id == Self.restoreID {
            working = false
            if let before = stashed {
                stashed = nil
                say("Las opciones de antes:")
                offer = before
            }
            return
        }

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
        // Hasta la prueba: la página se desplaza hasta ella y el cursor de
        // VoiceOver pasa a la página. Decir "está arriba" no alcanzaba: los
        // jueces no encontraban cómo llegar.
        if action.id == Self.toTestID {
            working = false
            reader.showChallenge()
            // Y el cursor se queda en la prueba: volver a ponerlo en "Ir a la
            // prueba" deshacía el salto.
            pageFocusRequests += 1
            lastDone = Self.toTestID
            say("La prueba quedó a la vista, en la página, con el asistente cerrado. Cuando esté resuelta, sigo solo y el asistente vuelve; si no, está el botón «Asistente».")
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
                await resume(pending, on: reader)
            } else {
                say("Todavía veo la prueba en la página. Cuando esté resuelta, continuamos.")
            }
            return
        }
        if action.id == Self.summaryID, let page = reader.page {
            await summarize(page)
            return
        }
        // El botón del formulario: lo tocó la persona, así que se aprieta. El
        // que se le ofreció, si fue por un pedido; si no, el de la página.
        if action.id == Self.submitID, let page = reader.page, let form = pendingSubmit ?? pageForm(page) {
            pendingSubmit = nil
            say("Pulsando «\(form.submit ?? action.label)».")
            await reader.submit(form)
            working = false
            await landed(reader)
            return
        }

        // "Ver más opciones" no lleva a ningún lado: trae los que quedaron.
        if action.id == Self.moreChoicesID {
            // Dichas en voz alta, porque quien no ve no las barre con la vista.
            say("Más opciones.", aloud: "Más opciones: " + pendingChoices.prefix(4).map(\.label).joined(separator: ". "))
            offerChoices(pendingChoices)
            return
        }
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
                // Sin repetir un titular que se acaba de tocar: se oía entero
                // —y cortado— antes de lo que importaba, que es la nota.
                let name = action.label.dropFirst("Abrir «".count).dropLast()
                say(name.count > 40 ? "Abriendo." : "Abriendo «\(name)».")
            } else {
                // El sitio que dice el botón, no el de la dirección: la de
                // un resultado de Google pasa por Google, y se oía
                // "Abriendo google.com" para cualquier resultado.
                let shown = action.label.components(separatedBy: " — ").last.flatMap(Self.bare)
                let host = Self.bare(Self.unicode(URL(string: href)?.host() ?? ""))
                say("Abriendo \(shown ?? host ?? action.label).")
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
            if opensNote, let page = reader.page, let kind = noticeKind(page), [.paywall, .login].contains(kind) {
                knownURL = page.url
                say("Esa nota es para suscriptores o pide iniciar sesión: el sitio me llevó a su página de ingreso.")
                offer = reader.canGoBack
                    ? Offer(goal: "", options: [.link(id: Self.backID, label: backLabel(reader), href: "", region: "main")])
                    : nil
                return
            }
            // Una pregunta que esperaba sitio: se contesta acá, sin describir.
            if let question = pendingQuestion, let page = reader.page {
                pendingQuestion = nil
                // Anotada: sin esto, Meteored cambiando su dirección al cargar
                // se anunciaba como "la página cambió".
                knownURL = page.url
                say("En \(page.displaySite).")
                working = true
                await reply(question, about: page)
                working = false
                return
            }
            // Si hay una tarea esperando, se sigue con ella sin orientar. En
            // Mercado Libre, JEF explicaba "usá el cuadro de texto que dice
            // Ingresá lo que quieras encontrar" y medio segundo después
            // buscaba él mismo.
            if let rest = waiting, let page = reader.page, !Self.hasChallenge(page) {
                waiting = nil
                knownURL = page.url
                offer = nil
                say("Estás en \(page.displaySite).")
                await continueWith(rest, on: reader)
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

        // Un formulario elegido como un paso —«Buscar en ANSES»—: se pregunta
        // el dato con el nombre del paso, no con el del campo («Search»), y
        // con todos sus datos se envía.
        if opensNote, target.kind == .form, let page = reader.page, let field = Self.field(named: target, in: page) {
            working = false
            if Self.isChallenge(field) {
                askToSolve(page, image: true)
                return
            }
            awaitingField = field
            completing = target
            say("«\(action.label)»: ¿qué escribo? Se puede escribir o dictar acá abajo.")
            inputRequests += 1
            return
        }

        // Un campo se llena, no se toca. Sin esto, aceptar "Buscar en
        // Wikipedia" volvía a apretar la lupa y a preguntar de nuevo: la
        // persona confirmaba una y otra vez sin que nada se escribiera.
        if let page = reader.page, let field = Self.field(named: target, in: page) {
            await write(field, of: target, goal: chosen.goal, on: reader)
            return
        }

        // El botón de un aviso: se toca y, si la página quedó en su lugar y
        // sin aviso, se siguen ofreciendo sus pasos, sin volver a contarla.
        if target.region == "overlay", let page = reader.page {
            let url = page.url
            await reader.activate(target)
            working = false
            if let now = reader.page, now.url == url, now.overlay == nil {
                say("Listo: el aviso se cerró.")
                offer = Offer(goal: "", options: known[url]?.steps ?? [])
                return
            }
            await landed(reader)
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

    /// Caminar la página hacia lo pedido. `said`: el pedido con las palabras
    /// de la persona, que es lo que juzgan Jev y Gemini; `goal`, lo que
    /// nombró el ruteador, sirve para encontrar la opción por su nombre. Con
    /// las del ruteador, "las noticias de economía" llegó como "Política y
    /// Economía" —un título de la portada— y Jev eligió Política.
    /// `orElse` y `question`: qué buscar afuera si no está, y la pregunta
    /// que se contesta allá, cuando el pedido era buscar.
    private func run(
        _ goal: String, on reader: ReaderModel, steps: Int, said: String? = nil,
        orElse: String? = nil, question: String? = nil
    ) async {
        guard let analyzer else {
            say("El asistente no está configurado en esta versión.")
            return
        }
        working = true
        defer { working = false }
        var first = true

        /// Tocar lo elegido. False: el turno terminó acá.
        func go(_ chosen: Action) async -> Bool {
            // Volver a tocar lo mismo es dar vueltas: no está acá. Se ofrece
            // buscarlo afuera. Antes decía "Sin avance" y ahí se terminaba.
            guard touched.insert(chosen.id).inserted else {
                say("No encuentro «\(Self.short(goal, 60))» en esta página. ¿Lo busco en internet?")
                searchInstead = goal
                return false
            }
            // Un campo se llena, no se toca. Y lo que se escribe sale
            // SÓLO de lo que la persona pidió: si un valor pudiera venir
            // de la página, un sitio podría hacer que JEF escriba lo que
            // se le antoje, y quien no ve no tendría cómo notarlo.
            if let page = reader.page, let field = Self.field(named: chosen, in: page) {
                await write(field, of: chosen, goal: goal, on: reader)
                return false
            }
            say("Abriendo \(chosen.label).")
            await reader.activate(chosen)
            return true
        }

        for _ in 0..<max(steps, 1) {
            guard let page = reader.page else {
                say("Todavía no hay una página cargada.")
                return
            }
            let options = openable(page)
            guard !options.isEmpty else {
                say("Esta página no ofrece nada que pueda abrir.")
                return
            }

            // Si lo pedido ES el nombre de una opción —"deportes" y el link
            // "Deportes"—, no hay nada que decidir. Preguntárselo a Jev era un
            // viaje de más, y una vez falló y "llevame a deportes" terminó en
            // "no pude decidir a dónde ir".
            // Y abierta, se llegó: se cuenta el lugar como cualquier llegada.
            // Preguntarle después a Jev si ya estaba terminaba en la
            // descripción de plantilla —"Estás en la portada de LA NACION"
            // parado en Deportes—.
            if first, let exact = Self.exactOption(for: goal, among: options), touched.insert(exact.id).inserted {
                say("Abriendo «\(exact.label)».")
                await reader.activate(exact)
                working = false
                await landed(reader)
                return
            }

            // Cuando Jev no puede, Gemini reinterpreta: elige uno o pregunta
            // entre dos o tres, con botones. Nil: tampoco encontró nada, y
            // dice cómo buscarlo afuera —con el sitio, si es de este sitio—.
            func rescue() async -> Action? {
                guard let answerer,
                      let found = try? await answerer.reinterpret(
                          said ?? goal, task: task, options: options.map { "\($0.kind.rawValue): \($0.label)" }, page: Self.saying(page))
                else { return nil }
                elsewhere = found.search
                if let index = found.choice { return options[index] }
                if let question = found.question, !found.options.isEmpty {
                    let offered = found.options.map { options[$0] }
                    // Una pregunta que no nombra sus propios botones no es
                    // confiable, y se descarta como una cifra inventada: en La
                    // Nación preguntó por «Política y Economía» y los botones
                    // eran tres titulares. Sin pregunta, sigue la salida de
                    // siempre.
                    guard Self.names(question, offered) else { return nil }
                    offer = Offer(goal: goal, options: offered)
                    say(question, aloud: question + " " + offered.map(\.label).joined(separator: ". "))
                    asked = true
                }
                return nil
            }
            var asked = false
            var elsewhere: String?

            // Cuál lleva a lo pedido, o ninguno: Jev, con la carrera. Con la
            // tarea delante: «medicina familiar» es otra cosa dentro de «quiero
            // sacar una cita en el IMSS». Pegada al pedido y no en un campo
            // aparte: medido ahí, en un campo aparte Jev tocaba «Suscribirse a
            // cita médica» (0,62); pegada, y con el link nombrado por su
            // tarjeta, el bueno (0,89).
            let request = jevRequest(said ?? goal)
            let found: PageAnalyzer.Found?
            if first, let ready = early, ready.url == page.url, ready.request == request, ready.ids == options.map(\.id) {
                found = await ready.answer.value
            } else {
                found = await analyzer.find(request, among: options, site: page.url)
            }
            early = nil
            Self.note(found, for: request, among: options)

            // Seguro de uno: se toca. Después del primer paso, más seguro: seguir
            // caminando sin la persona es más caro que frenar. En ANSES siguió
            // de la lista de trámites a «CONSULTAR TURNO» con 0,52.
            let sure = first ? Self.sureEnough : Criterios.actuales?.umbrales["cual_seguir"] ?? 1
            if let found, let index = found.choice, found.confidence >= sure {
                first = false
                guard await go(options[index]) else { return }
                continue
            }
            // Ya se movió: lo que no es un paso seguro es haber llegado. Seguir
            // preguntándole a Gemini daba vueltas por la sección —«Ver más
            // notas», otra vez «Política»— en vez de contar dónde estaba.
            guard first else { break }
            // Ninguno lleva, con seguridad: o lo pedido es esta misma página, o
            // seguro que no está, y se sale sin consultar a Gemini.
            if let found, found.choice == nil, found.confidence >= Self.sureEnough, let here = found.here {
                if here >= Criterios.actuales?.umbrales["esta_si"] ?? 1 {
                    working = false
                    await arrived(page)
                    return
                }
                if here <= Criterios.actuales?.umbrales["esta_no"] ?? 0 {
                    working = false
                    await searchElsewhere(orElse ?? said ?? goal, question: question, on: reader)
                    return
                }
            }
            // Jev no encontró a dónde ir, o duda: Gemini, con la página a la
            // vista. Encuentra lo que Jev no vio —el link escondido en el menú
            // de secciones— o dice cómo buscarlo afuera.
            if let chosen = await rescue() {
                first = false
                guard await go(chosen) else { return }
                continue
            }
            if asked { return }
            // Sin Gemini, la persona: el que Jev prefería, como pregunta.
            if answerer == nil, let index = found?.choice {
                offer = Offer(goal: goal, options: [options[index]])
                say("No es claro cuál. ¿\(options[index].label)?")
                return
            }
            // No está en esta página, donde la persona lo pidió: se busca
            // afuera, con el sitio si es de este sitio (Daniel: "siempre busca
            // en la página primero; si no, buscás afuera"). También después de
            // una pregunta de JEF: lo que no está entre los trámites de ANSES
            // —el pasaporte— lo resuelve el buscador, y la lista sigue a un
            // "Volver" de distancia.
            // Si el pedido era "abrir", es algo de este sitio: sin la
            // búsqueda de Gemini, va con el nombre del sitio. "Llevame a las
            // noticias de economía" desde La Nación trajo CNN y El País.
            working = false
            let own = orElse ?? "\(said ?? goal) \(page.displaySite)"
            await searchElsewhere(elsewhere ?? own, question: question, on: reader)
            return
        }

        await landed(reader)
    }

    /// No está en esta página: se busca afuera, diciéndolo. Con la pregunta,
    /// se contesta en los resultados o en el sitio que elija la persona.
    private func searchElsewhere(_ query: String, question: String?, on reader: ReaderModel) async {
        // En la página del buscador, buscar otra cosa es lo natural: no se
        // anuncia que no estaba.
        if reader.page.map({ Self.searchQuery(of: $0) == nil }) ?? true { say("No está en esta página.") }
        if let question { pendingQuestion = question }
        await arrive(query, on: reader)
    }

    /// Lo que se puede abrir en una página. En la del buscador, sus
    /// resultados, sin anuncios y en su orden: las pestañas, las imágenes y
    /// "También se buscó" son del buscador. Con «Turnos | ANSES», el epígrafe
    /// de una imagen, se abría el visor de imágenes de Google. En cualquier
    /// otra página, lo que ofrece, menos los links a la misma dirección.
    private func openable(_ page: ExtractedPage) -> [Action] {
        guard Self.searchQuery(of: page) != nil else {
            return Self.options(of: page).filter { Self.leadsAway($0, from: page) }
        }
        let found = organicCache.url == page.url ? organicCache.results : Self.results(of: page)
        return found.enumerated().map { index, result in
            .link(id: "res-\(index)-\(result.host)", label: "\(result.title) — \(result.host)", href: result.href, region: "main")
        }
    }

    /// Si una pregunta nombra cada una de sus opciones: el comienzo de cada
    /// etiqueta —hasta la primera coma, tres palabras— tiene que estar en el
    /// texto, sin mirar mayúsculas ni tildes.
    static func names(_ question: String, _ options: [Action]) -> Bool {
        let said = question.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber }).joined(separator: " ")
        return options.allSatisfy { option in
            let name = option.label.split(separator: ",").first.map(String.init) ?? option.label
            let words = name.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
                .split(whereSeparator: { !$0.isLetter && !$0.isNumber }).prefix(3).joined(separator: " ")
            return !words.isEmpty && said.contains(words)
        }
    }

    /// Si un destino lleva a otra página. Un link a la misma dirección no es
    /// un paso: en La Nación, «Ver más notas de Política» y «>Política»
    /// llevaban a /politica/, donde ya se estaba, y el asistente daba vueltas.
    /// Lo que no tiene dirección —un menú, un formulario— sí puede serlo.
    static func leadsAway(_ action: Action, from page: ExtractedPage) -> Bool {
        guard let href = action.href, let there = URL(string: href), let here = URL(string: page.url) else { return true }
        func key(_ url: URL) -> String {
            var path = url.path()
            while path.hasSuffix("/") { path.removeLast() }
            return (url.host() ?? "").lowercased() + path + (url.query().map { "?" + $0 } ?? "")
        }
        return key(there) != key(here)
    }

    /// Lo que eligió Jev, al registro: con esto se calibran los umbrales.
    private static func note(_ found: PageAnalyzer.Found?, for goal: String, among options: [Action]) {
        Registro.anotar("jev", [
            "pedido": goal,
            "eleccion": found.map { $0.choice.map { options[$0].label } ?? "ninguno" } ?? "sin respuesta",
            "confianza": found.map { String(format: "%.2f", $0.confidence) } ?? "",
            "esta": found?.here.map { String(format: "%.2f", $0) } ?? "",
        ])
    }

    /// Escribe en un campo lo que la persona pidió. Si lo que pidió es
    /// mandarlo —buscar, entrar—, lo decide el modelo y se aprieta el botón
    /// de la página; si no, el botón queda ofrecido.
    private func write(
        _ field: Action.Field, of form: Action, goal: String, on reader: ReaderModel
    ) async {
        guard let answerer else {
            say("Campo \(field.name) encontrado, pero no puedo escribir en esta versión.")
            return
        }
        let found: Answerer.FieldValue?
        do {
            found = try await answerer.value(for: field.name, from: goal)
        } catch {
            say("No pude preparar lo que hay que escribir. Probar de nuevo.")
            return
        }
        guard let found, personSaid(found.value, goal: goal) else {
            // Sin el dato en el pedido —o con uno que la persona no dijo—, se
            // le pregunta, como al tocar "Completar".
            awaitingField = field
            say("¿Qué pongo en \(Self.spoken(field))? Se puede escribir o dictar acá abajo: va directo a ese campo de la página.")
            inputRequests += 1
            return
        }

        await reader.type(found.value, into: field)
        filledFields.insert(field.id)
        say("Listo, escrito en \(Self.spoken(field)).")
        if found.send {
            working = false
            await submitAsked(form, on: reader)
        }
    }

    /// Si este formulario es un buscador, según el estándar: todos sus campos
    /// lo son (`type=search`, teclado de búsqueda, dentro del hito de
    /// búsqueda) o el formulario está en ese hito. Un buscador se envía
    /// solo cuando la persona lo pide; lo demás pasa por `submitAsked`.
    ///
    /// Antes lo adivinaban dos listas de palabras en castellano e inglés
    /// ("buscar", "continuar", "pagar"…): en cualquier otro idioma no
    /// reconocían nada. Un buscador que el HTML no declara se trata como un
    /// formulario común, y ahí juzga Jev.
    static func isSearch(_ form: Action) -> Bool {
        let fields = (form.fields ?? []).filter { $0.type != "hidden" }
        guard !fields.isEmpty else { return false }
        // Un dato secreto nunca es una búsqueda.
        guard !fields.contains(where: \.isSecure) else { return false }
        if form.region == "search" { return true }
        let fillable = fields.filter { $0.type != "checkbox" && $0.type != "radiogroup" }
        return !fillable.isEmpty && fillable.allSatisfy(\.isSearch)
    }

    /// Apretar el botón de un formulario porque la persona lo pidió, por voz
    /// o escribiendo, sin tocarlo.
    ///
    /// Un buscador se aprieta. Lo demás lo juzga Jev con la pregunta
    /// "¿compromete?" de `criterios.json`: por debajo del umbral se aprieta;
    /// por encima, si Jev duda o si no contesta a tiempo, el botón queda
    /// ofrecido con el nombre que le da la página y lo aprieta la mano. La
    /// voz pide; la mano confirma lo que compromete.
    private func submitAsked(_ form: Action, on reader: ReaderModel) async {
        let label = form.submit?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !Self.isSearch(form) {
            var risk: Double?
            if let analyzer, let page = reader.page {
                working = true
                risk = await analyzer.commits(button: label, form: form, page: page)
                working = false
            }
            Registro.anotar("compromete", ["boton": label, "p": risk.map { String(format: "%.2f", $0) } ?? "sin respuesta"])
            let limit = Criterios.actuales?.umbrales["compromete"] ?? 0
            guard let risk, risk < limit else {
                pendingSubmit = form
                say(label.isEmpty
                    ? "Ese botón puede confirmar algo: queda abajo, para tocarlo."
                    : "«\(label)» puede confirmar algo: queda abajo, para tocarlo.")
                offer = Offer(goal: "", options: [.link(id: Self.submitID, label: "Pulsar «\(label.isEmpty ? "enviar" : label)»", href: "", region: "main")])
                return
            }
        }
        working = true
        say("Pulsando «\(label.isEmpty ? "enviar" : label)».")
        await reader.submit(form)
        working = false
        await landed(reader)
    }

    /// Si la persona dijo ese valor: en este pedido, en el anterior o en la
    /// tarea que sigue. "Buscame auriculares" y después "¿cuánto sale el más
    /// barato?": lo que se escribe salió de ella, un turno antes. Nunca de la
    /// página.
    private func personSaid(_ value: String, goal: String) -> Bool {
        [goal, previousRequest, runningTask, task].compactMap { $0 }.contains { Self.said(value, in: $0) }
    }

    /// Si lo que se va a escribir en un campo lo dijo la persona. Se compara
    /// sin espacios ni signos, en cualquier escritura: "12 345 678" es
    /// "12345678". Lo que no aparece —el modelo lo transformó, o lo sacó de
    /// la página— no se escribe sin preguntar.
    static func said(_ value: String, in request: String) -> Bool {
        func bare(_ text: String) -> String {
            String(text.lowercased().unicodeScalars.filter { CharacterSet.alphanumerics.contains($0) }.map(Character.init))
        }
        let wanted = bare(value)
        return !wanted.isEmpty && bare(request).contains(wanted)
    }

    /// El campo que este destino representa, si lo es.
    static func field(named action: Action, in page: ExtractedPage) -> Action.Field? {
        guard action.kind == .form else { return nil }
        let fields = action.fields ?? []
        // El primero que todavía está vacío: es donde va lo que se pidió.
        return fields.first { $0.value.isEmpty && $0.type != "checkbox" } ?? fields.first
    }

    /// Contesta una pregunta sobre lo que la página dice.
    ///
    /// Lo que se puede contar, lo cuenta el código; lo que hay que redactar,
    /// lo redacta el modelo y lo respalda con una cita literal que se
    /// verifica contra la página. Si la cita no aparece, no se dice nada:
    /// para quien no ve, una invención sin verificar es indetectable.
    ///
    /// `quiet`: si la página no lo contesta, no decirlo ni ofrecer buscarlo,
    /// porque quien llama lo busca afuera. Devuelve si faltó.
    @discardableResult
    private func reply(_ question: String, about page: ExtractedPage, reading: String? = nil, quiet: Bool = false) async -> Bool {
        guard let answerer else {
            if quiet { return true }
            say("No puedo contestar preguntas en esta versión, pero sí navegar.")
            return false
        }
        let text = Self.saying(page)
        guard !text.isEmpty else {
            if quiet { return true }
            say("Esta página no tiene texto que pueda leer.")
            return false
        }
        do {
            guard let answer = try await answerer.answer(question, about: text, previous: previousRequest, reading: reading) else {
                if quiet { return true }
                say("Eso no aparece en esta página.")
                searchInstead = question
                return false
            }
            say(answer.text)
            remember(answer.text, on: page)
            nextQuestions = Self.fresh(answer.questions, after: question)
            // Sólo una parte: el resto, afuera, si la persona quiere.
            if answer.partial { searchInstead = question }
        } catch Answerer.AnswerError.transport {
            say("Sin conexión. Puedo leer la página, pero no contestar preguntas.")
        } catch {
            // Un error del modelo no es un problema de red, y decir que lo es
            // manda a la persona a revisar el wifi por nada. Pasó: la
            // respuesta venía cortada y el mensaje hablaba de la conexión.
            say("Algo falló de mi lado al contestar. Probar de nuevo, o preguntar de otra forma.")
        }
        return false
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
                .map { $0.isSecure ? "\(spoken($0)) (secreto)" : spoken($0) }
            guard !fields.isEmpty else { continue }
            let button = form.submit.map { " — button «\($0)»" } ?? ""
            content.append("FORM asking for: \(fields.joined(separator: ", "))\(button)")
        }
        // Un artículo no pasa por el recorrido: su texto vive en los bloques.
        if content.count < 8 {
            for block in page.blocks where !block.plainText.isEmpty { content.append(block.plainText) }
        }

        var out = "PAGE: \(page.displaySite) — \(page.sectionTitle)\n\n"
        out += "PAGE CONTENT (what the person came for):\n"
        out += content.joined(separator: "\n").prefix(20000)
        if !chrome.isEmpty {
            out += "\n\nSITE MENU, NOTICES AND SIDE DATA (not the content, but it can be asked about):\n"
            out += chrome.joined(separator: "\n").prefix(3000)
        }
        return metric(out)
    }

    /// Las medidas de Estados Unidos, pasadas a las de acá.
    ///
    /// El sitio del clima eligió solo, del lado del servidor, servir Córdoba
    /// en Fahrenheit y millas: "máxima de 63º" sin decir de qué, y quien no
    /// ve no tiene cómo sospechar que son 17 °C. Se convierte acá, antes de
    /// que lo lea nadie, y se avisa arriba que se convirtió.
    static func metric(_ text: String) -> String {
        guard text.range(of: "\\d\\s?mph\\b|\\d\\s?[°º]\\s?F\\b", options: .regularExpression) != nil else { return text }
        var out = text
        func convert(_ pattern: String, _ transform: (Double) -> String) {
            guard let regex = try? NSRegularExpression(pattern: pattern) else { return }
            let source = out as NSString
            var result = ""
            var last = 0
            for match in regex.matches(in: out, range: NSRange(location: 0, length: source.length)) {
                result += source.substring(with: NSRange(location: last, length: match.range.location - last))
                let number = source.substring(with: match.range(at: 1)).replacingOccurrences(of: ",", with: ".")
                // El original, antes: capturado por el `??`, NSString no es
                // Sendable y la compilación Release no archivaba.
                let original = source.substring(with: match.range)
                result += Double(number).map(transform) ?? original
                last = match.range.location + match.range.length
            }
            out = result + source.substring(from: last)
        }
        func whole(_ value: Double) -> String { String(Int(value.rounded())) }
        // Con "°F" escrito, o sin letra en una página que mide el viento en
        // millas: "63º 40º" junto a "13 mph".
        convert("(-?\\d+(?:[.,]\\d+)?)\\s?[°º]\\s?F\\b") { "\(whole(($0 - 32) * 5 / 9)) °C" }
        convert("(-?\\d+(?:[.,]\\d+)?)\\s?[°º](?!\\s?[CcFf]\\b)") { "\(whole(($0 - 32) * 5 / 9)) °C" }
        convert("(\\d+(?:[.,]\\d+)?)\\s?mph\\b") { "\(whole($0 * 1.609)) km/h" }
        convert("(\\d+(?:[.,]\\d+)?)\\s?in\\b") { $0 * 25.4 < 10 && $0 > 0
            ? String(format: "%.1f mm", $0 * 25.4).replacingOccurrences(of: ".", with: ",")
            : "\(whole($0 * 25.4)) mm" }
        convert("(\\d+(?:[.,]\\d+)?)\\s?mi\\b") { "\(whole($0 * 1.609)) km" }
        return "(This page came in US units; here they are converted to °C, km/h, mm and km.)\n" + out
    }

    /// Cómo se le nombra a Gemini un elemento del mapa. Lo del menú y el pie,
    /// dicho: la orientación ve ahora la página entera —en La Nación,
    /// «Economía» está en el menú y no la veía—, y tiene que saber qué es
    /// contenido. Un formulario, con lo que pide y su botón: por el nombre
    /// solo no se sabe si es un boletín.
    static func described(_ action: Action) -> String {
        guard action.kind == .form else {
            switch action.region {
            case "header", "banner", "nav", "navigation": return "\(short(action.label, 80)) (menu)"
            case "footer", "contentinfo": return "\(short(action.label, 80)) (footer)"
            case "overlay": return "\(short(action.label, 80)) (on the notice covering the page)"
            default: return short(action.label, 80)
            }
        }
        let fields = (action.fields ?? []).filter { $0.type != "hidden" }.map(spoken).joined(separator: ", ")
        let button = action.submit.map { " — button «\($0)»" } ?? ""
        return "FORM «\(action.label)» asking for: \(fields)\(button)"
    }

    static let readID = "jef-leer"
    static let summaryID = "jef-resumir"
    static let continueID = "jef-seguir"
    static let submitID = "jef-enviar-formulario"
    /// "Completar «…»": lo que sigue es el id del campo.
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
            // Las opciones, como vinieron: el orden lo decidió quien las armó.
            // Acá se ponía todo formulario primero, y en ANSES los dos primeros
            // botones eran «Completar «buscador»» y «Pulsar «Search»».
            var options = current.options
            // Volver, aunque las opciones las haya armado el modelo: sin él,
            // salir de una página equivocada obligaba a escribir.
            let isResults = options.contains { $0.id.hasPrefix("res-") }
            if reader.canGoBack, !isResults, !options.contains(where: { $0.id == Self.backID }) {
                options.append(.link(id: Self.backID, label: backLabel(reader), href: "", region: "main"))
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
            options.append(.link(id: Self.outsidePrefix + "buscá en internet: " + question,
                                 label: "Buscarlo en internet", href: "", region: "main"))
        }
        if failedTurn, let request = lastRequest {
            options.append(.link(id: Self.askPrefix + request, label: "Intentar de nuevo", href: "", region: "main"))
        }
        if let page = reader.page {
            options += followUps(page, canGoBack: reader.canGoBack, back: backLabel(reader))
        } else if options.isEmpty {
            options = Self.starters
        }
        // Volver no se cae al recortar: era lo primero que desaparecía.
        let back = options.first { $0.id == Self.backID }
        // Cinco como tope: tres titulares, "Seguir con los titulares" y
        // "Volver". Con cuatro, "Seguir" era el que se caía.
        var kept = Array(options.filter { $0.id != Self.backID }.prefix(back == nil ? 5 : 4))
        if let back { kept.append(back) }
        offer = Offer(goal: "", options: kept + [other])
    }

    /// "Volver" diciendo adónde: "Volver a la página anterior" en una
    /// portada no decía si era a la nota o a los resultados.
    private func backLabel(_ reader: ReaderModel) -> String {
        guard let back = reader.backPlace else { return "Volver a la página anterior" }
        if let host = URL(string: back.url)?.host()?.lowercased(),
           host.contains("duckduckgo.") || host.contains("google.") {
            return "Volver a los resultados"
        }
        let path = URL(string: back.url)?.path ?? ""
        if path.isEmpty || path == "/" { return "Volver a la portada" }
        // Sin el nombre del sitio que los títulos llevan al final: "Solicitar
        // turnos en ANSES | Argentina.gob.ar".
        var title = back.title.trimmingCharacters(in: .whitespaces)
        if let cut = title.range(of: "\\s[|–—-]\\s[^|–—-]+$", options: .regularExpression),
           title.distance(from: title.startIndex, to: cut.lowerBound) >= 15 {
            title = String(title[..<cut.lowerBound])
        }
        return title.isEmpty ? "Volver a la página anterior" : "Volver a «\(Self.short(title, 60))»"
    }

    /// Lo que sigue, según la página y lo último que se hizo en ella.
    private func followUps(_ page: ExtractedPage, canGoBack: Bool, back: String = "Volver a la página anterior") -> [Action] {
        func option(_ id: String, _ label: String) -> Action {
            .link(id: id, label: label, href: "", region: "main")
        }
        let reading = page.url == readingURL && readingFrom > 0
        let more = reading && readingFrom < readablePieces(page).count
        let summarized = lastDone == Self.summaryID
        var out: [Action] = []

        if challenge != nil || Self.hasChallenge(page) {
            // Llevar hasta la prueba, y por si el sitio no avisa cuando se
            // resuelve, que la persona lo diga. Ya en la prueba, lo que sigue
            // es decir que se resolvió.
            let test = [option(Self.toTestID, "Ir a la prueba"), option(Self.solvedID, "Ya la resolví")]
            var out = lastDone == Self.toTestID ? test.reversed() : test
            // Y otro camino, para quien no puede o no quiere resolverla.
            var task: String?
            switch challenge?.resume {
            case .question(let pending), .rest(let pending): task = pending
            default: task = challenge?.elsewhere
            }
            if let task {
                out.append(.link(id: Self.outsidePrefix + "buscá en internet: " + task,
                                 label: "Buscarlo en otro sitio", href: "", region: "main"))
            }
            return out + (canGoBack ? [option(Self.backID, back)] : [])
        }

        if let query = Self.searchQuery(of: page) {
            // En la página del buscador lo probable es uno de los resultados:
            // los ya filtrados, sin anuncios, si son de esta página.
            let found = organicCache.url == page.url ? organicCache.results : Self.results(of: page)
            for (index, result) in found.prefix(3).enumerated() {
                out.append(.link(id: "res-\(index)-\(result.host)", label: "\(result.title) — \(result.host)",
                                 href: result.href, region: "main"))
            }
            return out
        }

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
                if canGoBack { out.append(option(Self.backID, back)) }
                return out
            }
        } else if more {
            out.append(option(Self.continueID, "Seguir leyendo"))
        }
        // Lo que la orientación propuso para esta página, menos lo que ya se
        // hizo. Antes se armaba acá con otras reglas —el formulario primero,
        // «Leer» y «Resumir» según el código creyera que era una nota—, y se
        // pisaban con las de la llegada.
        let done = Set([lastDone, reading ? Self.readID : nil, summarized ? Self.summaryID : nil].compactMap { $0 })
        if let steps = known[page.url]?.steps {
            out += steps.filter { !done.contains($0.id) && $0.id != Self.backID }
        } else if !readablePieces(page).isEmpty {
            if !reading { out.append(option(Self.readID, "Leer la página")) }
            if !summarized { out.append(option(Self.summaryID, "Resumir la página")) }
        }
        if canGoBack { out.append(option(Self.backID, back)) }
        // Volver al final y siempre: recortando, era lo primero que se caía.
        let back = out.first { $0.id == Self.backID }
        let rest = out.filter { $0.id != Self.backID }
        return Array(rest.prefix(back == nil ? 4 : 3)) + (back.map { [$0] } ?? [])
    }

    /// Un titular sin su volanta: "Por carta. El secretario de Discapacidad…"
    /// es "El secretario de Discapacidad…". La volanta no es lo que se dijo,
    /// y con el rotor un botón se reconoce por sus primeras palabras.
    static func dekick(_ title: String) -> String {
        guard let range = title.range(of: "^[^.!?]{2,32}\\.\\s+(?=[A-ZÁÉÍÓÚÑ¿¡\"«])", options: .regularExpression),
              title[range].split(separator: " ").count <= 5 else { return title }
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
            if entry.kind == "link", (entry.title ?? entry.label).map(tidy) == title, let href = entry.href { return href }
            if entry.kind == "listing", let listing = entry.ref.flatMap({ byID[$0] }),
               let href = listing.items.first(where: { tidy($0.title) == title })?.href {
                return href
            }
        }
        return nil
    }

    /// El formulario de la página, para cuando se pide su botón:
    /// en el que ya se escribió algo —también un buscador: en Mercado Libre
    /// quedaba escrito y sin forma de apretar «Buscar»—, o si no, el primero
    /// que no es de búsqueda.
    /// `noise`: los formularios que Gemini marcó como ruido al llegar —el del
    /// boletín en Meteored— no se ofrecen.
    static func pageForm(_ page: ExtractedPage, filled: Set<String> = [], skipping noise: Set<String> = []) -> Action? {
        page.actions.first { $0.kind == .form && ($0.fields ?? []).contains { filled.contains($0.id) } }
            ?? page.actions.first { $0.kind == .form && !isSearch($0) && !noise.contains($0.id) && !($0.fields ?? []).isEmpty }
    }

    /// El de esta página, con lo que ya se escribió y sin lo que es ruido.
    private func pageForm(_ page: ExtractedPage) -> Action? {
        Self.pageForm(page, filled: filledFields, skipping: noiseIDs(of: page))
    }

    /// Lo que Gemini marcó como ruido en esta página, si es ésta.
    private func noiseIDs(of page: ExtractedPage) -> Set<String> {
        noisy.url == page.url ? noisy.ids : []
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
            present(await organic(page).results, for: query, speak: false)
            return
        }
        offer = nil
        say("De vuelta en \(whereIs(page)).")
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
            panelRequests += 1
            say("Listo, ya pasamos la verificación.")
            await resume(pending, on: reader)
            closeTurn(on: reader)
            return
        }
        // Misma página si cambia sólo la consulta o el "#": Meteored actualiza
        // su dirección apenas carga, y se anunciaba "la página cambió" sobre
        // la misma página.
        guard !inTurn, !working, Self.place(page.url) != knownURL.map(Self.place) else { return }
        inTurn = true
        defer { inTurn = false }
        interruptNext = true
        if page.overlay?.kind == .captcha {
            say("La página cambió.")
            describe(page)
        } else {
            knownURL = page.url
            offer = nil
            say("La página cambió: ahora estás en \(whereIs(page)).")
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
        // Y el botón ofrecido para la mano también era de la otra página.
        pendingSubmit = nil
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
            let (found, ads) = await organic(page)
            if !found.isEmpty {
                present(found, for: query, ads: ads)
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
        // El mapa de la página, el mismo que ve Jev: las marcas del modelo
        // son posiciones en él.
        let map = Self.options(of: page)
        working = true
        // Qué sitio y qué página es: Jev, en medio segundo, con las opciones
        // de `criterios.json`. Lo que dice con seguridad le llega a la
        // orientación como dato —en una tienda lo probable es buscar; en un
        // trámite, elegir de una lista— y decide cómo se lee la página; si
        // duda, lo decide el modelo (Daniel).
        let kinds = await self.kinds(of: page, map: map)
        let sure = Criterios.actuales?.umbrales["tipo"] ?? 1
        if let kinds, let notice = kinds.notice, kinds.noticeConfidence >= sure { notices[page.url] = notice }
        if let overlay = page.overlay, let kind = noticeKind(page) {
            text = "A NOTICE COVERS THE PAGE (\(kind.rawValue)): \(overlay.text)\n\n" + text
        }
        let said = [
            kinds.flatMap { $0.siteConfidence >= sure ? "site: \($0.site)" : nil },
            kinds.flatMap { $0.pageConfidence >= sure ? "page: \($0.page)" : nil },
        ].compactMap { $0 }
        var orientation: Answerer.Orientation?
        do {
            orientation = try await answerer.orient(
                page: text, candidates: map.map(Self.described), goal: task,
                kinds: said.isEmpty ? nil : said.joined(separator: "; "))
        } catch {
            // Por qué se cayó a la descripción: en una prueba pasó en Clarín
            // y no había cómo saber si fue la red o una cifra sin verificar.
            Registro.anotar("error", ["orientar": String(describing: error)])
        }
        working = false
        guard let orientation else { describe(page); return }
        // Qué es la página: lo de Jev si estaba seguro, si no lo del modelo,
        // que la leyó. Lo demás —leer, "Volver a la portada", lo que se
        // ofrece después— lo pregunta acá.
        var kind = orientation.kind
        if let kinds, kinds.pageConfidence >= sure {
            kind = kinds.page == "front_page" ? .portada : kinds.page == "article" ? .nota : .otra
        }
        Registro.anotar("tipo", [
            "url": page.url, "sitio": kinds?.site ?? "", "p_sitio": kinds.map { String(format: "%.2f", $0.siteConfidence) } ?? "",
            "pagina": kinds?.page ?? "", "p_pagina": kinds.map { String(format: "%.2f", $0.pageConfidence) } ?? "",
            "modelo": orientation.kind.rawValue,
            "aviso": kinds?.notice ?? "", "p_aviso": kinds.map { String(format: "%.2f", $0.noticeConfidence) } ?? "",
            "aviso_extractor": page.overlay?.kind.rawValue ?? "",
        ])
        known[page.url] = (kind, [])
        // En una portada, los titulares que se nombran y los botones son los
        // mismos porque los elige el código: los primeros de la página. Dejando
        // que el modelo eligiera los botones por número, nombraba unos y
        // ofrecía otros.
        var lead = readsHeadlines(page) ? Array(Self.headlines(of: page).prefix(4)) : []
        var spoken = lead.map(Self.dekick)
        // Lo que Gemini llamó ruido: por id, para esta página. No se sugiere
        // —tampoco su formulario—, pero Jev lo sigue viendo al navegar.
        noisy = (page.url, Set(orientation.noise.compactMap { map.indices.contains($0 - 1) ? map[$0 - 1].id : nil }))
        let noisyLabels = orientation.noise.compactMap { map.indices.contains($0 - 1) ? map[$0 - 1].label : nil }
        Registro.anotar("ruido", ["url": page.url, "elementos": noisyLabels])
        // Tampoco entre los titulares, que elige el código: en StubHub, con
        // cara de portada, los "titulares" eran partidos de Miami que Gemini
        // ya había marcado como ruido, y se decían igual.
        let noisyTitles = Set(noisyLabels.map(Self.tidy))
        lead = lead.filter { !noisyTitles.contains(Self.tidy($0)) }
        spoken = lead.map(Self.dekick)

        remember(orientation.text, on: page)
        if lead.isEmpty {
            // Con la pregunta, en el mismo mensaje: "¿Para qué trámite?" y los
            // trámites como botones. Sin repetirla si el texto ya la hace.
            // Sin repetirla si el texto ya pregunta: "¿cuál necesitás? ¿Qué
            // trámite deseas realizar?" eran dos preguntas seguidas.
            if let question = orientation.question, !orientation.text.contains(where: { "?¿？؟".contains($0) }) {
                say("\(orientation.text) \(question)")
            } else {
                say(orientation.text)
            }
        } else {
            // Los titulares, tal cual los escribió el diario y dichos por el
            // código. Reescritos por el modelo salían distintos en cada visita
            // —tres versiones del mismo titular de Adorni— y con cosas que no
            // estaban ("sobreseyó a un acusado"). En pantalla no se repiten:
            // son los botones que siguen.
            let list = spoken.enumerated().map { "\($0.offset + 1). \(Self.sentence($0.element))" }.joined(separator: " ")
            // Una frase que el modelo dejó abierta para los titulares —"Estás
            // en la portada de Clarín y sus titulares son:"— queda colgando:
            // el lugar lo dice la plantilla.
            // Y de lo que dijo, sólo la primera oración: pedido que no nombre
            // titulares, igual agregaba las cotizaciones del dólar.
            let said = orientation.text.trimmingCharacters(in: .whitespaces)
            let first = said.range(of: ". ").map { String(said[..<$0.lowerBound]) + "." } ?? said
            let intro = first.hasSuffix(":") ? "Estás en \(whereIs(page))." : first
            say("\(intro) Los titulares principales son las primeras opciones.",
                aloud: "\(intro) Los titulares principales: \(list)")
            leadSaid = lead.count
        }
        let what = isArticle(page) ? Self.the(page) : "la página"
        let options: [Action] = orientation.suggestions.compactMap { suggestion in
            switch suggestion.kind {
            case .abrir:
                guard let number = suggestion.number, map.indices.contains(number - 1) else { return nil }
                let target = map[number - 1]
                targets["sug-\(target.id)"] = target
                return Action(
                    // El título de lo que abre, no el del modelo: en Clarín
                    // un botón que decía "Abrir noticia de la visita de León
                    // XIV" abría otra nota, y "Abriendo www.clarin.com" no
                    // dejaba notarlo. Un botón de la página, con su nombre.
                    id: "sug-\(target.id)", kind: target.kind,
                    label: target.kind == .link ? "Abrir «\(Self.short(target.label))»" : Self.short(target.label), href: target.href,
                    fields: nil, submit: nil, notices: nil, region: target.region,
                    unnamed: nil, cluster: nil, primary: nil, fresh: nil
                )
            case .completar:
                // Un formulario es un solo paso, con el nombre de lo que hace:
                // «Buscar en ANSES», y no «Completar «buscador»» y «Pulsar
                // «Search»», dos botones técnicos para lo mismo (Daniel).
                guard let number = suggestion.number, map.indices.contains(number - 1),
                      map[number - 1].kind == .form else { return nil }
                let form = map[number - 1]
                targets["sug-\(form.id)"] = form
                return .link(id: "sug-\(form.id)", label: suggestion.label, href: "", region: form.region)
            // Leer y resumir los hace el código, y el botón lo dice él: GLM
            // ofrecía «Leer el resumen del artículo» y leía el artículo.
            case .leer:
                return .link(id: Self.readID, label: "Leer \(what)", href: "", region: "main")
            case .resumir:
                return .link(id: Self.summaryID, label: "Resumir \(what)", href: "", region: "main")
            }
        }
        // En el orden que dio el modelo: es el de lo más probable para lo que
        // la persona vino a hacer. Antes el código lo pisaba en las notas
        // —leer y resumir primero, otra nota a lo sumo si compartía una raíz
        // de cinco letras con el título—, y eso no andaba con "PAMI" ni en
        // otro idioma.
        var ordered = options
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
            // Los cuatro ya se dijeron: "dame los titulares" sigue desde el
            // quinto en vez de repetirlos.
            readingURL = page.url
            readingFrom = lead.count
            // En una portada el modelo sugiere sólo para lo que la persona vino
            // a hacer, si no es leer noticias: eso va primero. Sin tarea no
            // hay para qué, y se verifica acá: GLM sugería «LO ÚLTIMO» y
            // «Lima - navegación principal» antes que los titulares.
            let hrefs = Set(named.compactMap(\.href))
            let forGoal = task == nil ? [] : ordered.filter { $0.id.hasPrefix("sug-") && !hrefs.contains($0.href ?? "") }.prefix(2)
            ordered = Array(forGoal) + named + ordered.filter { !$0.id.hasPrefix("sug-") }
        }
        // Una opción por id: dos "leer" con el mismo id eran, para VoiceOver,
        // el mismo botón dos veces con nombres distintos.
        var ids = Set<String>(), labels = Set<String>()
        ordered = ordered.filter { ids.insert($0.id).inserted && labels.insert(Self.flatten($0.label)).inserted }
        known[page.url] = (kind, ordered)
        // Una pregunta se contesta con sus opciones: van ellas, no las
        // sugerencias. En ANSES, con "sacar un turno", se ofrecían consultar y
        // reprogramar uno ya sacado, y los trámites no estaban.
        let choices: [Action] = orientation.choices.compactMap { number in
            guard orientation.question != nil, map.indices.contains(number - 1) else { return nil }
            let target = map[number - 1]
            targets["sug-\(target.id)"] = target
            return Action(
                id: "sug-\(target.id)", kind: target.kind, label: Self.short(target.label), href: target.href,
                fields: nil, submit: nil, notices: nil, region: target.region,
                unnamed: nil, cluster: nil, primary: nil, fresh: nil
            )
        }
        if !choices.isEmpty {
            // En el orden de la página, que es el del mapa: el modelo las
            // devuelve en el suyo, y "Solicitud de Jubilación", segunda en
            // ANSES, salía cuarta.
            let position = Dictionary(map.enumerated().map { ($1.id, $0) }, uniquingKeysWith: { first, _ in first })
            offerChoices(choices.sorted {
                position[targets[$0.id]?.id ?? ""] ?? .max < position[targets[$1.id]?.id ?? ""] ?? .max
            })
        } else if !ordered.isEmpty {
            offer = Offer(goal: "", options: ordered)
        }
        // Un aviso que pide una decisión de la persona —las cookies, la edad—
        // se contesta primero, como lo haría quien ve: sus botones van
        // adelante y decide ella; la app no acepta ni rechaza por nadie. Todos
        // sus botones: con tres, en El Mundo quedaban «Iniciar sesión»,
        // «nuestros socios» y «Configuración», y ni aceptar ni rechazar. Menos
        // lo que el modelo llamó ruido, pero nunca todos: la salida no se
        // pierde. La propaganda —bajar la app, el boletín— no se pone
        // adelante: no le impide nada a JEF, que toca la página por debajo, y
        // en Liverpool se ofrecía «Descarga». Sigue en el mapa, por si la
        // persona pide cerrarla.
        if let overlay = page.overlay, let kind = noticeKind(page), [.cookies, .age].contains(kind) {
            let wanted = overlay.choices.filter { !noiseIDs(of: page).contains($0.id) }
            let covering = (wanted.isEmpty ? overlay.choices : wanted).map { choice in
                targets["sug-\(choice.id)"] = Self.button(choice)
                return Self.button(choice, id: "sug-\(choice.id)")
            }
            let rest = (offer?.options ?? []).filter { option in !covering.contains { $0.id == option.id } }
            if !covering.isEmpty { offer = Offer(goal: "", options: covering + rest) }
        }
    }

    /// Las opciones de una pregunta que no entraron: "Ver más opciones" las
    /// trae de a cuatro, como los resultados del buscador.
    private var pendingChoices: [Action] = []
    static let moreChoicesID = "jef-mas-de-la-lista"

    private func offerChoices(_ choices: [Action]) {
        pendingChoices = Array(choices.dropFirst(4))
        var options = Array(choices.prefix(4))
        if !pendingChoices.isEmpty {
            options.append(.link(id: Self.moreChoicesID, label: "Ver más opciones (\(pendingChoices.count))", href: "", region: "main"))
        }
        offer = Offer(goal: "", options: options)
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

        say("Estás en \(whereIs(page)).")

        // 1. Una portada: titulares que se abren.
        let headlines = Self.headlines(of: page)
        if !headlines.isEmpty, !isArticle(page) {
            // Sin el total: "Hay 35 notas" contaba lo que el sitio repite.
            say(headlines.count == 1 ? "Dice:" : "Las primeras notas:")
            for title in headlines.prefix(3) { say(Self.dekick(title)) }
            // Como si se hubieran leído: las opciones son abrir ésas y seguir,
            // no "Leer los titulares", que repetía las mismas tres.
            readingURL = page.url
            readingFrom = min(3, headlines.count)
            lastChunk = 0..<min(3, headlines.count)
            lastDone = Self.readID
            return
        }

        // 2. Una nota para leer. Se pide párrafo largo y no sólo muchos
        //    caracteres: los recortes de una página de resultados suman
        //    caracteres de sobra y no son una nota.
        let paragraphs: [String] = page.blocks.compactMap {
            if case .paragraph(_, let text, _) = $0 { return text } else { return nil }
        }
        if isArticle(page), let opening = paragraphs.first(where: { $0.count >= 160 }) {
            // Contados como los cuenta la lectura: decía "una nota de 7
            // párrafos" y después leía "párrafos 1 a 2 de 6".
            let count = readablePieces(page).count
            say("\(Self.isWiki(page) ? "Es un artículo" : "Es una nota") de \(count) párrafos. Empieza así:")
            say(Self.opening(opening, 280))
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
            say("Indicar qué poner y lo completo.")
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

    /// Todo lo que la página deja tocar o abrir, esté o no en la pantalla, en
    /// el orden en que la página lo muestra: el mapa de la página. Lo ven
    /// igual Jev, la orientación y reinterpretar —los mismos elementos, el
    /// mismo orden, los mismos nombres—; antes cada uno veía una lista propia,
    /// y en ANSES «CONSULTAR TURNO» le llegaba a Gemini antes que los
    /// trámites, aunque en la página está abajo.
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
            guard !action.label.isEmpty, seen.insert(key).inserted else { return }
            out.append(action)
        }
        // Un formulario es un destino: significa "escribí acá". Sin él,
        // "busca Buenos Aires" no tiene a dónde ir y el asistente termina
        // abriendo y cerrando la lupa.
        func usable(_ action: Action) -> Bool {
            action.unnamed != true && (action.kind != .form || !(action.fields ?? []).isEmpty)
        }

        // Lo que tapa la página va primero: sus botones son lo primero que se
        // puede tocar, como para quien ve. La prueba anti-robot no: se
        // resuelve en la página.
        if let overlay = page.overlay, overlay.kind != .captcha {
            for choice in overlay.choices { add(Self.button(choice)) }
        }
        let actions = Dictionary(page.actions.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        let byID = Dictionary(page.listings.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        for entry in page.stream ?? [] {
            switch entry.kind {
            case "action":
                if let action = entry.ref.flatMap({ actions[$0] }), usable(action) { add(action) }
            case "link":
                // Una tarjeta se ofrece por su titular, no por todo lo que dice;
                // un link que no se nombra solo, con el nombre de su tarjeta.
                guard let label = entry.title ?? entry.label, let href = entry.href else { continue }
                add(.link(id: entry.id, label: entry.context.map { "\($0) — \(label)" } ?? label, href: href, region: entry.zone))
            case "listing":
                guard let listing = entry.ref.flatMap({ byID[$0] }) else { continue }
                for (index, item) in listing.items.enumerated() {
                    guard let href = item.href else { continue }
                    add(.link(id: "\(listing.id)-\(index)", label: item.title, href: href, region: entry.zone))
                }
            case "block":
                // Los links que viven adentro de un párrafo —"Ingresá a
                // Solicitud de turnos"—, que no son controles sueltos.
                guard case .paragraph(let id, let text, let links)? = entry.block else { continue }
                let units = Array(text.utf16)
                for (index, link) in links.enumerated() {
                    let lower = max(0, min(link.start, units.count)), upper = max(lower, min(link.end, units.count))
                    let label = String(decoding: units[lower..<upper], as: UTF16.self).trimmingCharacters(in: .whitespaces)
                    add(.link(id: "\(id)-l\(index)", label: label, href: link.href, region: entry.zone))
                }
            default:
                continue
            }
        }
        // Lo que el recorrido no ubicó, al final: que nada quede afuera.
        for action in page.actions where usable(action) { add(action) }
        // Jev admite 255 opciones por pregunta. Medido, no documentado.
        return Array(out.prefix(240))
    }

    /// El pedido como lo recibe Jev: con la tarea delante, si es más que el
    /// pedido. Ver `run`.
    private func jevRequest(_ words: String) -> String {
        task.map { $0 == words ? words : "\($0): \(words)" } ?? words
    }

    /// Lo que Jev dice de esta página: con qué se juzga es lo que se ve de
    /// ella —su dominio, título, títulos, el comienzo del contenido y lo
    /// primero del mapa—, en un estado chico.
    private func kinds(of page: ExtractedPage, map: [Action]) async -> PageAnalyzer.Kinds? {
        guard let analyzer else { return nil }
        var headings: [String] = []
        for entry in page.stream ?? [] {
            if case .heading(_, _, let text)? = entry.block, !text.isEmpty { headings.append(text) }
            if entry.kind == "link", entry.level != nil, let title = entry.title ?? entry.label { headings.append(title) }
        }
        let content = Self.saying(page).components(separatedBy: "PAGE CONTENT (what the person came for):\n").last ?? ""
        let domain = URL(string: page.url)?.host()?.lowercased() ?? ""
        return await analyzer.kinds(
            domain: domain.hasPrefix("www.") ? String(domain.dropFirst(4)) : domain, title: page.title,
            headings: headings, text: content,
            items: map.prefix(30).map { (text: $0.label, kind: $0.kind.rawValue, region: $0.region.isEmpty ? "main" : $0.region) },
            overlay: page.overlay?.kind == .captcha ? nil : page.overlay)
    }

    /// Qué pidió el aviso de cada página, según Jev, cuando lo dijo seguro.
    private var notices: [String: String] = [:]

    /// Qué pide el aviso que tapa la página: lo de Jev si lo dijo con
    /// seguridad —en cualquier idioma; el extractor lo adivina con palabras
    /// ("cookie", "consentimiento") y a la promoción de Foodit la llamaba
    /// "otro"—; si no, lo del extractor. La prueba anti-robot tiene su propio
    /// camino y no se le pregunta a Jev.
    private func noticeKind(_ page: ExtractedPage) -> Overlay.Kind? {
        guard let overlay = page.overlay else { return nil }
        guard overlay.kind != .captcha else { return .captcha }
        switch notices[page.url] {
        case "cookies": return .cookies
        case "login": return .login
        case "paywall": return .paywall
        case "newsletter": return .newsletter
        case "age": return .age
        case "app", "promo", "other": return .other
        default: return overlay.kind
        }
    }

    /// Un botón de un aviso que tapa la página, como un elemento del mapa. El
    /// extractor le puso su marca, así que se toca como cualquier control.
    static func button(_ choice: Overlay.Choice, id: String? = nil) -> Action {
        Action(
            id: id ?? choice.id, kind: .button, label: choice.label, href: nil, fields: nil, submit: nil,
            notices: nil, region: "overlay", unnamed: nil, cluster: nil, primary: nil, fresh: nil
        )
    }

    /// El lugar, con el nombre que le daría una persona: "la portada de La
    /// Nación", no "«Últimas noticias de Argentina y el mundo», LA NACION".
    func whereIs(_ page: ExtractedPage) -> String {
        if let query = Self.searchQuery(of: page) { return "los resultados de «\(query)»" }
        if readsHeadlines(page) {
            // Deportes no es la portada: la portada es la raíz del sitio.
            let path = URL(string: page.url)?.path ?? "/"
            if path.isEmpty || path == "/" { return "la portada de \(page.displaySite)" }
            return "la sección «\(Self.short(page.sectionTitle, 60))» de \(page.displaySite)"
        }
        if isArticle(page) {
            let title = Self.short(page.sectionTitle, 90)
            // Wikipedia no tiene notas: tiene artículos.
            if page.url.contains("wikipedia.org") { return "el artículo «\(title)» de Wikipedia" }
            return "la nota «\(title)», de \(page.displaySite)"
        }
        return "«\(Self.short(page.sectionTitle, 90))», \(page.displaySite)"
    }

    /// Wikipedia no tiene notas: tiene artículos. "Leer la nota" sobre Mar
    /// del Plata sonaba a diario.
    static func isWiki(_ page: ExtractedPage) -> Bool { page.url.contains("wikipedia.org") }
    static func the(_ page: ExtractedPage) -> String { isWiki(page) ? "el artículo" : "la nota" }
    static func of(_ page: ExtractedPage) -> String { isWiki(page) ? "del artículo" : "de la nota" }

    /// Un texto que termina como una oración, para que la voz haga la pausa.
    static func sentence(_ text: String) -> String {
        let clean = text.trimmingCharacters(in: .whitespaces)
        guard let last = clean.last else { return clean }
        // Después de unas comillas también: "…como si el dinero “no
        // existiera”" seguido del número siguiente se oía sin pausa.
        return ".!?…".contains(last) ? clean : clean + "."
    }

    /// El comienzo de un párrafo, cortado donde termina una oración: "…la
    /// localidad balnear" era lo último que se oía del adelanto de Wikipedia.
    static func opening(_ text: String, _ limit: Int) -> String {
        guard text.count > limit else { return text }
        let head = String(text.prefix(limit))
        // El último fin de oración que entra.
        var end: String.Index?
        var index = head.startIndex
        while index < head.endIndex {
            let next = head.index(after: index)
            if ".!?".contains(head[index]), next < head.endIndex, head[next] == " " { end = index }
            index = next
        }
        if let end, head.distance(from: head.startIndex, to: end) >= 60 {
            return String(head[...end])
        }
        return short(text, limit)
    }

    /// Las palabras del pedido con las tildes con que las escribió la
    /// persona: el ruteador devuelve "clarin" por "clarín".
    static func inTheirWords(_ target: String, from request: String?) -> String {
        guard let request else { return target }
        var theirs: [String: String] = [:]
        for word in request.split(whereSeparator: { !$0.isLetter && !$0.isNumber }) {
            theirs[flatten(String(word))] = String(word)
        }
        return target.split(separator: " ", omittingEmptySubsequences: false).map { word in
            let key = flatten(String(word))
            guard let own = theirs[key], own.count == word.count,
                  own.lowercased() != word.lowercased() else { return String(word) }
            return word.first?.isUppercase == true ? own.prefix(1).uppercased() + own.dropFirst() : own
        }.joined(separator: " ")
    }

    /// Los titulares de esta página: un link que además es encabezado, o un
    /// ítem de listado con nombre largo que abre otra página. La misma regla
    /// que decide si algo es una portada.
    static func headlines(of page: ExtractedPage) -> [String] {
        var out: [String] = []
        var seen = Set<String>()
        // Una nota por dirección: el título y la bajada de la misma tarjeta
        // son dos links a la misma nota. En Deportes de La Nación, "El ciclo
        // de Hansi Flick…" —la bajada de la primera— se contaba como la
        // segunda nota.
        var opened = Set<String>()
        let byID = Dictionary(page.listings.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        for entry in page.stream ?? [] {
            // Veinte letras como piso: "Medidas de Milei" y "Dólar hoy" son
            // etiquetas de sección del ticker, no notas.
            if entry.kind == "link", entry.level != nil, let href = entry.href,
               let label = (entry.title ?? entry.label).map(tidy), label.count >= 20 {
                if seen.insert(label).inserted, opened.insert(place(href)).inserted { out.append(label) }
            }
            if entry.kind == "listing", let listing = entry.ref.flatMap({ byID[$0] }) {
                for item in listing.items where item.title.count >= 25 {
                    guard let href = item.href else { continue }
                    let title = tidy(item.title)
                    if seen.insert(title).inserted, opened.insert(place(href)).inserted { out.append(title) }
                }
            }
        }
        return out
    }
}
