import SwiftUI
import WebKit

/// The live page, shown as-is.
///
/// The fallback. Whatever the native rebuild cannot handle — a captcha, an
/// anti-bot wall, a payment iframe, a page that did not extract — the user
/// must still be able to get through it, with VoiceOver reading the web the
/// ordinary way. Worse than the native view; incomparably better than "could
/// not read this page" and nowhere to go.
///
/// This is the engine's own WKWebView, not a copy. The session, the form the
/// user half filled, the captcha they just solved: all of it is still there
/// when they switch back, and anything they navigate to here is extracted
/// and waiting on the native side.
struct WebPageView: UIViewRepresentable {
    let webView: WKWebView

    func makeUIView(context: Context) -> WKWebView {
        webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
