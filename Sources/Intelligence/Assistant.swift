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
                // Sin repetir el dato entero: un DNI dicho en voz alta en la
                // calle no. Las tres últimas cifras alcanzan para confirmarlo.
                say(field.isSecure
                    ? "Listo: quedó escrita en «\(Self.spoken(field))»."
                    : "Listo: quedó escrito en «\(Self.spoken(field))», terminado en \(goal.suffix(3)).")
                return
            }
        }

        // Una dirección es una dirección. Buscarla adentro de la página —que
        // es lo que hacía— termina ofreciendo "¿querés que vaya a Inicio?"
        // cuando lo que se pidió fue google.com.
        if let url = ReaderModel.normalize(goal), goal.contains(".") , !goal.contains(" ") {
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

            if let decision {
                await carry(decision.action, of: decision, goal: goal, on: reader)
                // El segundo pedido de una frase que traía dos: "resumime y
                // después entrame a la de Milei". Descartarlo en silencio era
                // uno de los errores que la medición encontró. Si se quedó
                // esperando un dato, el segundo espera: enviar sin el dato no.
                if let next = decision.then, !working, awaitingField == nil {
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
        guard reader.page != nil else {
            await arrive(goal, on: reader)
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
                let name = spoken(field) + (field.isSecure ? " (contraseña)" : "")
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
            goal, state: state, place: Ubicacion.shared.place,
            page: page.map(Self.saying), controls: controls.map(\.label)
        )
        // Sin el valor: un DNI dictado no va al registro.
        Registro.anotar("decision", [
            "accion": decision.action.rawValue, "target": decision.target ?? "", "reference": decision.reference ?? "",
            "question": decision.question ?? "", "control": decision.control.map(String.init) ?? "",
            "then": decision.then?.rawValue ?? "", "rest": decision.rest ?? "",
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
            // Si salió de una pregunta, se contesta en el sitio que elija.
            // Buscar en el buscador del sitio, o contestar con la página
            // abierta, ya no lo decide acá el código: lo decide el modelo,
            // que ve la página (completar + enviar, o responder).
            if let question = decision.question { pendingQuestion = question }
            await arrive(decision.target ?? goal, on: reader)

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
            let progress = readingProgress(page).map {
                "\n(La persona está escuchando la lectura de esta página: va por el bloque \($0.at) de \($0.of).)"
            } ?? ""
            await reply(goal + progress, about: page)
            working = false

        case .completar:
            await complete(decision, goal: goal, on: reader)

        case .enviar:
            guard let page = reader.page,
                  let form = control(decision)?.form ?? Self.pageForm(page, filled: filledFields)
            else { say("Acá no hay un formulario para enviar."); return }
            working = true
            say("Pulsando «\(form.submit ?? "enviar")».")
            await reader.submit(form)
            working = false
            await landed(reader)

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
        let goal = Self.inTheirWords(goal, from: lastRequest)

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
        // Y en el orden del buscador, sin reordenar: medido contra 162
        // búsquedas reales de sitios con dueño conocido, el primero de
        // DuckDuckGo era el correcto en el 98 % y el correcto estaba entre
        // los tres primeros en todas. Las reglas propias que lo reordenaban
        // —país, "lo oficial primero", coincidencias— lo empeoraban: en un
        // iPhone con región Estados Unidos subieron una copia de la banca
        // del Banco Nación alojada en vercel.app por encima del banco. Lo
        // decidió Daniel (2026-09-21): el orden es el del buscador, y la
        // persona elige entre los tres primeros.
        present(found, for: goal)
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
        let byID = Dictionary(page.listings.map { ($0.id, $0) }, uniquingKeysWith: { first, _ in first })
        for entry in page.stream ?? [] {
            switch entry.kind {
            case "link":
                if let label = entry.label, let href = entry.href { found.append((label, href)) }
            case "listing":
                guard let listing = entry.ref.flatMap({ byID[$0] }) else { continue }
                for item in listing.items { if let href = item.href { found.append((item.title, href)) } }
            default: continue
            }
        }
        return results(from: found)
    }

    /// Los resultados de verdad entre los links de una página de buscador,
    /// en su orden. Aparte de la página para poder probarla contra búsquedas
    /// guardadas: ver Tests/buscador.
    static func results(from links: [(title: String, href: String)]) -> [Result] {
        var out: [Result] = []
        var seen = Set<String>()

        func consider(_ title: String, _ href: String) {
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
        for link in results.isEmpty ? links : results { consider(link.title, link.href) }
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
        // El cartel que la página le puso al lado vale más que su id.
        // Salvo una contraseña: lo que tiene escrito es la contraseña.
        let fallback = field.isSecure ? "" : field.value
        if !fallback.isEmpty { return fallback }
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

    /// Una página que vende una suscripción. Su formulario no es un paso: el
    /// de ingreso del banco sí lo es, y por eso no alcanza con `isWall`.
    static func isSubscription(_ page: ExtractedPage) -> Bool {
        if page.overlay?.kind == .paywall { return true }
        let text = (page.url + " " + page.title).folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
        return text.range(of: "suscri|subscri|paywall", options: .regularExpression) != nil
    }

    /// Una página que tapa la nota que se quería leer: pedir suscripción,
    /// iniciar sesión, o un captcha.
    static func isWall(_ page: ExtractedPage) -> Bool {
        if let kind = page.overlay?.kind, [.paywall, .login, .captcha].contains(kind) { return true }
        let text = (page.url + " " + page.title).folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
        return text.range(of: "suscri|subscri|registr|login|signin|sign-in|iniciar sesion|/ingresar", options: .regularExpression) != nil
    }

    /// Las preguntas sugeridas que no son la que se acaba de contestar: después
    /// de "¿y el oficial?", ofrecer "¿Y el dólar oficial?" era repetirla.
    /// Ni las que la respuesta ya contestó: después de "La fundó Patricio
    /// Peralta Ramos" se ofrecía "¿Quién la fundó?".
    static func fresh(_ questions: [String], after asked: String, answered: String = "") -> [String] {
        let done = stems(asked)
        let said = stems(answered)
        // Las palabras de preguntar no cuentan: "quién", "cuánto", "dónde".
        let asking: Set<String> = ["quien", "cuant", "donde", "cuand", "porqu"]
        return questions.filter { question in
            let own = stems(question).subtracting(asking)
            return !stems(question).subtracting(done).isEmpty && (own.isEmpty || !own.isSubset(of: said))
        }
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

    /// Las raíces de las palabras con contenido: "turno" en "Turnos" y en
    /// "sacar un turno". Para saber si una opción tiene que ver con un pedido.
    static func stems(_ text: String) -> Set<String> {
        let words = text.split(whereSeparator: { !$0.isLetter }).map { flatten(String($0)) }
        return Set(words.filter { $0.count >= 5 }.map { String($0.prefix(5)) })
    }

    /// Si lo escrito es un dato para un campo —un DNI, un mail, un nombre— y
    /// no un pedido nuevo. Por la forma: corto, y sin empezar como un pedido.
    /// Si el pedido pregunta un dato, en vez de pedir ir a algún lado.
    static func isQuestion(_ text: String) -> Bool {
        let flat = text.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
            .trimmingCharacters(in: .whitespaces)
        return text.contains("?") || flat.range(
            of: "^(a )?(que|cual|cuanto|cuanta|como|donde|cuando|quien)\\b", options: .regularExpression
        ) != nil
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
        let end = readsHeadlines(page) ? "Fin de los titulares." : Self.isArticle(page) ? "Fin \(Self.of(page))." : "Fin de la página."

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
            let heard = saidHere.url == page.url && !saidHere.text.isEmpty
                ? " La persona ya escuchó esto: «\(saidHere.text)». No lo repitas: contá lo que falta (lo que sigue, el contexto, lo que dicen los involucrados)."
                : ""
            guard let answer = try await answerer.answer(
                "Resumí esta página en dos frases, con los hechos concretos: qué pasó, quién, cuándo, las cifras. Si es una cobertura en vivo, lo último que informa. Nada de describir la página («informa sobre…»): los hechos.\(heard)", about: text
            ) else {
                readTheOpening()
                return
            }
            // Diciendo de qué: "resumime la nota" con la nota sin abrir
            // resumía la portada, y nadie se enteraba de que era la portada.
            // Qué se resume, sin repetir el título entero, que ya se escuchó
            // al llegar: "resumime la nota" con la nota sin abrir resumía la
            // portada sin decirlo.
            let what = readsHeadlines(page) ? "la portada" : Self.isArticle(page) ? Self.the(page) : "la página"
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
        // El botón del formulario: lo tocó la persona, así que se aprieta.
        if action.id == Self.submitID, let page = reader.page, let form = Self.pageForm(page, filled: filledFields) {
            say("Pulsando «\(form.submit ?? action.label)».")
            await reader.submit(form)
            working = false
            await landed(reader)
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
            if opensNote, let page = reader.page, Self.isWall(page) {
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
            let options = Self.options(of: page)
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
                          goal, options: options.map { "\($0.kind.rawValue): \($0.label)" }, page: Self.saying(page))
                else { return nil }
                elsewhere = found.search
                if let index = found.choice { return options[index] }
                if let question = found.question, !found.options.isEmpty {
                    offer = Offer(goal: goal, options: found.options.map { options[$0] })
                    say(question)
                    asked = true
                }
                return nil
            }
            var asked = false
            var elsewhere: String?
            func notFound() {
                say("No encuentro «\(Self.short(goal, 60))» en esta página. ¿Lo busco en internet?")
                searchInstead = elsewhere ?? goal
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
                // Jev falló: Gemini reinterpreta.
                if let chosen = await rescue() {
                    first = false
                    guard await go(chosen) else { return }
                    continue
                }
                if asked { return }
                // Tampoco Gemini lo encontró: está en otro lado. Se ofrece
                // buscarlo, con un botón (Daniel: "no encuentro X en esta
                // página, te propongo buscarlo en la web, ¿lo hago?").
                notFound()
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
                working = false
                await arrived(page)
                return

            case .ask, .go where decision.confidence < Self.sureEnough:
                // Jev duda: Gemini reinterpreta antes de preguntar a ciegas.
                if let chosen = await rescue() {
                    guard await go(chosen) else { return }
                    continue
                }
                if asked { return }
                if answerer != nil {
                    notFound()
                    return
                }
                // Dos con el mismo nombre no son una elección: "¿Cuentas?
                // También encuentro Cuentas" en el Banco Nación.
                var named = Set<String>()
                let candidates = decision.ranked.prefix(4).compactMap { index in
                    options.indices.contains(index) ? options[index] : nil
                }.filter { named.insert(Self.flatten($0.label)).inserted }.prefix(2)
                guard let first = candidates.first else {
                    say("No encontré eso en esta página.")
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
                    say("No encontré eso en esta página.")
                    return
                }
                guard await go(options[index]) else { return }
            }
        }

        await landed(reader)
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
        guard let found else {
            // Sin el dato en el pedido, se le pregunta, como al tocar
            // "Completar".
            awaitingField = field
            say("¿Qué pongo en \(Self.spoken(field))? Se puede escribir o dictar acá abajo: va directo a ese campo de la página.")
            inputRequests += 1
            return
        }

        await reader.type(found.value, into: field)
        filledFields.insert(field.id)
        say("Listo, escrito en \(Self.spoken(field)).")
        if found.send {
            say("Pulsando «\(form.submit ?? "enviar")».")
            await reader.submit(form)
            await landed(reader)
        }
    }

    /// Si este formulario sólo busca. Ya no decide si se envía —eso lo
    /// decide la persona o el modelo—: sólo evita ofrecer "Completar" con el
    /// buscador del encabezado en cada página.
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
        return fields.first { $0.value.isEmpty && $0.type != "checkbox" } ?? fields.first
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
            remember(answer.text, on: page)
            nextQuestions = Self.fresh(answer.questions, after: question, answered: saidHere.text)
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
                result += Double(number).map(transform) ?? source.substring(with: match.range)
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
        return "(Esta página venía en medidas de Estados Unidos; acá están pasadas a °C, km/h, mm y km.)\n" + out
    }

    /// Qué se abre, en qué orden: los titulares primero, después el resto de
    /// lo que la página ofrece. La lista que ve el modelo empieza por lo que
    /// una persona quiere de una portada.
    static func candidates(of page: ExtractedPage, goal: String? = nil) -> [Action] {
        let all = options(of: page)
        let headlines = Set(headlines(of: page))
        let first = all.filter { headlines.contains(tidy($0.label)) }
        // Del resto, sólo lo que está en el contenido: "Ya tenés tu tarjeta
        // 365?" y "Correo electrónico" salían como opciones de una nota.
        let chrome: Set<String> = ["header", "banner", "nav", "navigation", "footer", "contentinfo"]
        // Ni pagar, ni suscribirse, ni bajar una app: en Clarín se sugería
        // suscribirse, y en el banco, la app — que no se usa desde acá.
        // Ni reproductores: "Escuchar nota" o "Reproducir audio" harían sonar
        // algo encima de VoiceOver.
        var paying = "suscri|subscri|premium|comprar|pagar|descarg|app store|google play|apple store|abrir app|abrir la app"
            + "|escuchar|reproducir|podcast|compartir|imprimir|guardar"
        // Ni iniciar sesión, salvo que la persona haya venido a eso: en una
        // nota del Papa se ofrecía "Abrir «Iniciar sesión»".
        // Sólo en un diario, donde es ruido. En un banco, ingresar es lo
        // principal: en bna.com.ar faltaba "Home Banking" entre las opciones.
        let flatGoal = (goal ?? "").folding(options: [.diacriticInsensitive, .caseInsensitive], locale: nil)
        let news = isArticle(page) || headlines.count >= 8
        if news, flatGoal.range(of: "cuenta|sesion|ingres|entrar|login|home ?banking|usuario|clave", options: .regularExpression) == nil {
            paying += "|iniciar sesion|inicia sesion|ingresar|ingresa a tu|mi cuenta|registrate|crear cuenta|log ?in|sign ?in"
        }
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
    static let submitID = "jef-enviar-formulario"
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
            // Salvo en un muro: el formulario de suscripción de Clarín no es
            // un paso que alguien vino a dar.
            let form = reader.page.flatMap { Self.isSubscription($0) ? nil : Self.formOptions($0, except: filledFields.union(waitingFor)) } ?? []
            var options = form + current.options.filter { option in !form.contains { $0.id == option.id } }
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
            options.append(.link(id: Self.askPrefix + "buscá en internet: " + question,
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
                out.append(.link(id: Self.askPrefix + "buscá en internet: " + task,
                                 label: "Buscarlo en otro sitio", href: "", region: "main"))
            }
            return out + (canGoBack ? [option(Self.backID, back)] : [])
        }

        if let query = Self.searchQuery(of: page) {
            // En la página del buscador lo probable es uno de los resultados.
            let found = Self.results(of: page)
            for (index, result) in found.prefix(3).enumerated() {
                out.append(.link(id: "res-\(index)-\(result.host)", label: "\(result.title) — \(result.host)",
                                 href: result.href, region: "main"))
            }
            return out
        }

        if !Self.isSubscription(page) {
            out += Self.formOptions(page, except: filledFields.union(awaitingField.map { [$0.id] } ?? []))
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
            out.append(option(Self.readID, "Leer los titulares"))
            if !summarized { out.append(option(Self.summaryID, "Resumir la portada")) }
        } else if Self.isArticle(page) {
            if more { out.append(option(Self.continueID, "Seguir leyendo")) }
            else if !reading { out.append(option(Self.readID, "Leer \(Self.the(page))")) }
            if !summarized { out.append(option(Self.summaryID, "Resumir \(Self.the(page))")) }
        } else if !readablePieces(page).isEmpty {
            if more { out.append(option(Self.continueID, "Seguir leyendo")) }
            else if !reading { out.append(option(Self.readID, "Leer la página")) }
            if !summarized { out.append(option(Self.summaryID, "Resumir la página")) }
        }
        if canGoBack { out.append(option(Self.backID, back)) }
        // Volver al final y siempre: recortando, era lo primero que se caía.
        let back = out.first { $0.id == Self.backID }
        let rest = out.filter { $0.id != Self.backID }
        return Array(rest.prefix(back == nil ? 3 : 2)) + (back.map { [$0] } ?? [])
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

    /// Un formulario que no es de búsqueda —el ingreso de un banco— se
    /// completa: ése es el paso que sigue, y no había forma de darlo sin
    /// saber escribir el pedido justo. La contraseña también, desde el chat
    /// como el DNI: lo pidió Daniel. Y su botón, con el nombre que le da la página: en el Banco Nación,
    /// con DNI y usuario escritos, no había cómo tocar «Continuar».
    static func formOptions(_ page: ExtractedPage, except filled: Set<String> = []) -> [Action] {
        guard let form = pageForm(page, filled: filled) else { return [] }
        let fillable = (form.fields ?? []).filter {
            $0.type != "hidden" && $0.type != "checkbox" && !isChallenge($0) && !filled.contains($0.id)
        }
        var options: [Action] = fillable.prefix(2).map { field in
            let name = spoken(field)
            return .link(id: askPrefix + "completá el campo \(name)", label: "Completar «\(name)»", href: "", region: "main")
        }
        if let button = form.submit?.trimmingCharacters(in: .whitespacesAndNewlines), !button.isEmpty {
            options.append(.link(id: submitID, label: "Pulsar «\(button)»", href: "", region: "main"))
        }
        return options
    }

    /// El formulario que ofrece `formOptions`, para cuando se toca su botón:
    /// en el que ya se escribió algo —también un buscador: en Mercado Libre
    /// quedaba escrito y sin forma de apretar «Buscar»—, o si no, el primero
    /// que no es de búsqueda.
    static func pageForm(_ page: ExtractedPage, filled: Set<String> = []) -> Action? {
        page.actions.first { $0.kind == .form && ($0.fields ?? []).contains { filled.contains($0.id) } }
            ?? page.actions.first { $0.kind == .form && !isSearch($0) && !($0.fields ?? []).isEmpty }
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
            present(Self.results(of: page), for: query, speak: false)
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
                present(found, for: query)
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
        let candidates = Self.candidates(of: page, goal: lastRequest)
        // En una portada, los titulares que se nombran y los botones son los
        // mismos porque los elige el código: los primeros de la página. Dejando
        // que el modelo eligiera los botones por número, nombraba unos y
        // ofrecía otros.
        let lead = readsHeadlines(page) ? Array(Self.headlines(of: page).prefix(4)) : []
        let spoken = lead.map(Self.dekick)
        working = true
        var orientation: Answerer.Orientation?
        do {
            orientation = try await answerer.orient(
                page: text, candidates: candidates.map(\.label), goal: lastRequest, frontPage: !lead.isEmpty
            )
        } catch {
            // Por qué se cayó a la descripción: en una prueba pasó en Clarín
            // y no había cómo saber si fue la red o una cifra sin verificar.
            Registro.anotar("error", ["orientar": String(describing: error)])
        }
        working = false
        guard let orientation else { describe(page); return }

        remember(orientation.text, on: page)
        if lead.isEmpty {
            say(orientation.text)
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
            // Y sólo si tiene que ver: en la nota del apagón se ofrecía "Clave
            // Única PAMI".
            let topic = Self.stems(page.title)
            let others = ordered.filter { $0.id.hasPrefix("sug-") && !Self.stems($0.label).isDisjoint(with: topic) }.prefix(1)
            ordered = [.link(id: Self.readID, label: "Leer \(Self.the(page))", href: "", region: "main"),
                       .link(id: Self.summaryID, label: "Resumir \(Self.the(page))", href: "", region: "main")] + Array(others)
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
            // Los cuatro ya se dijeron: "dame los titulares" sigue desde el
            // quinto en vez de repetirlos.
            readingURL = page.url
            readingFrom = lead.count
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

        say("Estás en \(whereIs(page)).")

        // 1. Una portada: titulares que se abren.
        let headlines = Self.headlines(of: page)
        if !headlines.isEmpty, !Self.isArticle(page) {
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
        if Self.isArticle(page), let opening = paragraphs.first(where: { $0.count >= 160 }) {
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
                // Una tarjeta se ofrece por su titular, no por todo lo que dice.
                guard let label = entry.title ?? entry.label, let href = entry.href else { continue }
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
        if Self.isArticle(page) {
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
