import Foundation

/// What a person came to a page to do.
///
/// A fixed taxonomy rather than free-form text, for two reasons: Jev answers
/// typed questions and cannot generate labels, and a stable set keeps the
/// question wording — and therefore the calibration — constant across sites.
///
/// Seven buckets cover the overwhelming majority of the web. An airline home
/// page alone spans five of them: book (`transact`), check in (`manage`),
/// flight status (`lookup`), miles (`account`), lost baggage (`support`).
enum Intent: String, CaseIterable, Codable, Sendable, Identifiable {
    case read
    case transact
    case manage
    case lookup
    case account
    case support
    case compare
    /// Catch-all for institutional and policy content. Exists so the other
    /// buckets stay clean: without it, "Proveedores" and "SkyTeam" land in
    /// `support` and pollute a group the user actually needs.
    case info

    var id: String { rawValue }

    /// Shown to the user. Phrased as what a person wants, never as a category.
    ///
    /// Earlier versions grouped by DOM structure — "Enlaces de navegación",
    /// "Pie de página". Nobody thinks "I want to go to the footer". Every
    /// grouping the app invents has to be one a person would recognise.
    var label: String {
        switch self {
        case .read:     return "Leer el contenido"
        case .transact: return "Comprar o reservar"
        case .manage:   return "Gestionar lo que ya tengo"
        case .lookup:   return "Consultar un dato"
        case .account:  return "Mi cuenta"
        case .support:  return "Ayuda"
        case .compare:  return "Comparar opciones"
        case .info:     return "Información del sitio"
        }
    }

    /// Groups are ordered by how likely the user wants them, but `info` is a
    /// bucket of leftovers and always sinks, however it scored.
    var isCatchAll: Bool { self == .info }

    /// The criteria Jev judges against. These are the actual prompt: they must
    /// describe the page's affordances, not the user's feelings, because the
    /// state Jev sees is the page.
    var criteria: String {
        switch self {
        case .read:
            return "The page's main value is prose to read: an article, a post, documentation, a reference entry."
        case .transact:
            return "The page lets you start a purchase, booking, reservation or payment — a checkout, a booking form, an add-to-cart."
        case .manage:
            return "The page lets you change, cancel, check in to, or track something you already have."
        case .lookup:
            return "The page lets you look up one specific fact or status, such as a flight status, an order number, an opening time."
        case .account:
            return "The page lets you sign in, register, or reach a personal account area."
        case .support:
            return "The page lets you contact support, file a claim, or reach help documentation."
        case .compare:
            return "The page presents several options side by side to choose between: a listing, search results, a pricing table."
        case .info:
            return "General information about the company, its services, policies or partners — institutional content rather than a task."
        }
    }
}

/// Actions that serve one intent, presented as a single collapsed group.
///
/// Replaces the earlier DOM-shaped grouping. The user sees "Comprar o
/// reservar", not "Contenido principal", and the groups are ordered by how
/// likely they are to be what the user came for.
struct IntentGroup: Identifiable, Sendable {
    let intent: Intent
    let actions: [Action]
    /// Actions Jev placed here with low confidence. Kept in the group — moving
    /// them to a limbo bucket helps nobody — but the UI can flag them.
    let uncertain: Set<String>

    var id: String { intent.rawValue }
    var label: String { intent.label }
    var count: Int { actions.count }
}

/// What the app decides to do after asking Jev.
///
/// The three outcomes exist because guessing wrong is worse than not guessing.
/// For a sighted user a bad guess is an annoyance; for someone navigating
/// linearly with VoiceOver it hides the one thing they came for.
enum IntentDecision: Sendable, Equatable {
    /// One intent dominates. Reorder without asking.
    case assume(Intent)
    /// Several are plausible. Ask, offering these in order.
    case ask([Intent])
    /// Nothing is clear enough to act on. Render untouched.
    case undecided

    var isAsking: Bool { if case .ask = self { return true }; return false }
}

/// Per-intent probability from Jev, with the routing rules applied in code.
struct IntentScores: Sendable {
    /// "Does the page offer this?" — one probability per intent.
    let probabilities: [Intent: Double]
    /// "What is the page mainly for?" — a single choice.
    ///
    /// Separate from the booleans on purpose. A page offering sign-in scores
    /// high on `account` whether sign-in is the point of the page or a link in
    /// the header; this says which it is.
    let primary: Intent?
    let primaryConfidence: Double?

    init(
        probabilities: [Intent: Double],
        primary: Intent? = nil,
        primaryConfidence: Double? = nil
    ) {
        self.probabilities = probabilities
        self.primary = primary
        self.primaryConfidence = primaryConfidence
    }

    /// Intents above the noise floor, strongest first.
    ///
    /// The page's primary task is promoted to the front when it qualifies, so
    /// the option a visitor most likely came for is the first one they hear.
    var ranked: [(intent: Intent, probability: Double)] {
        let sorted = probabilities
            .map { (intent: $0.key, probability: $0.value) }
            .sorted { $0.probability > $1.probability }

        guard
            let primary,
            (primaryConfidence ?? 0) >= 0.5,
            let index = sorted.firstIndex(where: { $0.intent == primary }),
            index > 0
        else { return sorted }

        var promoted = sorted
        promoted.insert(promoted.remove(at: index), at: 0)
        return promoted
    }

    /// Turns probabilities into a decision.
    ///
    /// Thresholds are starting points, not truths. TypeSafe's own guidance is
    /// to calibrate them against labelled data for the domain; nothing here has
    /// been calibrated against real pages yet, so they are deliberately
    /// conservative — the failure mode we accept is asking too often, never
    /// reordering on a bad guess.
    func decide(
        dominant: Double = 0.75,
        plausible: Double = 0.45,
        maxOptions: Int = 5,
        tieBand: Double = 0.1
    ) -> IntentDecision {
        let sorted = ranked
        guard let top = sorted.first, top.probability >= plausible else {
            return .undecided
        }

        // A clear winner: high on its own AND well clear of the runner-up.
        // The gap matters as much as the absolute value — two intents at 0.8
        // each is an ambiguous page, not a confident one.
        if top.probability >= dominant {
            let runnerUp = sorted.dropFirst().map(\.probability).max() ?? 0
            if top.probability - runnerUp >= 0.25 {
                return .assume(top.intent)
            }
        }

        var contenders = sorted.filter { $0.probability >= plausible }

        // Cutting at a fixed count drops legitimate options when scores cluster:
        // on a real airline page five intents landed between 0.85 and 0.93, and
        // a hard limit of four hid "check flight status" for no reason other
        // than its position. Keep everything within `tieBand` of the last
        // option that fits, so near-ties survive together.
        if contenders.count > maxOptions {
            let cutoff = contenders[maxOptions - 1].probability
            contenders = contenders.filter { $0.probability >= cutoff - tieBand }
        }

        return .ask(contenders.map(\.intent))
    }
}
