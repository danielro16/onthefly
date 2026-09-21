import SwiftUI
import WebKit

/// La página, tal como es.
///
/// No se reconstruye ni se reordena: VoiceOver la lee como lee cualquier web,
/// y la persona puede no tocarla nunca y hacer todo hablando con el
/// asistente. Queda a la vista para quien ve, y para lo que sólo la persona
/// puede hacer: una contraseña, un captcha, el botón de pagar.
///
/// Es el WKWebView del motor, no una copia. Lo que se haga acá —iniciar
/// sesión, resolver un captcha, navegar— es lo mismo que el asistente ve.
struct WebPageView: UIViewRepresentable {
    let webView: WKWebView

    func makeUIView(context: Context) -> WKWebView {
        webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
