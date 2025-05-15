//
//  WebView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Displays legal agreement webpage within a WebView.

import SwiftUI
@preconcurrency import WebKit

@MainActor
struct WebView: UIViewRepresentable {
    let url: URL
    let onError: (() -> Void)?

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        if uiView.url != url {
            uiView.load(URLRequest(url: url))
        }
    }

    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(self, onFinishedLoading: nil, onError: onError)
    }
}

@MainActor
class WebViewCoordinator: NSObject, WKNavigationDelegate {
    var parent: WebView
    var onFinishedLoading: (() -> Void)?
    var onError: (() -> Void)?

    let allowedURLs: [String] = [
        ContentConstants.ContentStrings.privatePolicyURL,
        ContentConstants.ContentStrings.termsAndConditionsURL
    ]

    init(_ parent: WebView, onFinishedLoading: (() -> Void)?, onError: (() -> Void)?) {
        self.parent = parent
        self.onFinishedLoading = onFinishedLoading
        self.onError = onError
    }

    func webView(
        _ webView: WKWebView,
        shouldStartLoadWith request: URLRequest,
        navigationType: WKNavigationType
    ) -> Bool {
        guard let url = request.url else { return true }

        for allowedURL in allowedURLs where url.absoluteString == allowedURL {
            return true
        }
        showAlertForRestrictedAccess(webView)
        return false
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        onFinishedLoading?()
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        onError?()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        onError?()
    }

    func showAlertForRestrictedAccess(_ webView: WKWebView) {
        let alert = UIAlertController(
            title: "Restricted Access",
            message: "You cannot access this website.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        if let topController = webView.window?.rootViewController {
            topController.present(alert, animated: true, completion: nil)
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    WebView(
        url: URL(string: ContentConstants.ContentStrings.privatePolicyURL)!,
        onError: nil
    )
}
#endif
