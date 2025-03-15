//
//  WebViewService.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Class manages the state of a web view for loading URLs.

import Foundation

@MainActor
public final class WebViewService: ObservableObject {
    @Published var urlString: String?
    @Published var showWebView: Bool
    @Published var showAlert: Bool
    @Published var alertTitle: String
    @Published var alertMessage: String
    @Published var webViewURL: URL?

    init(
        urlString: String? = nil,
        showWebView: Bool = false,
        showAlert: Bool = false,
        alertTitle: String = "",
        alertMessage: String = "",
        webViewURL: URL? = nil
    ) {
        self.urlString = urlString
        self.showWebView = showWebView
        self.showAlert = showAlert
        self.alertTitle = alertTitle
        self.alertMessage = alertMessage
        self.webViewURL = webViewURL
    }

    func loadWebView(urlString: String, type: WebViewType) {
        let allowedURL = [
            ContentConstants.ContentStrings.privatePolicyURL,
            ContentConstants.ContentStrings.termsAndConditionsURL
        ]
        if allowedURL.contains(urlString), let url = URL(string: urlString) {
            webViewURL = url
            showWebView = true
        } else {
            setAndShowAlert(for: type)
        }
    }

    func handleWebViewError(type: WebViewType) {
        showWebView = false
        setAndShowAlert(for: type)
    }

    func dismissWebView() {
        showWebView = false
    }

    func updateShowWebView(_ value: Bool) {
        showWebView = value
    }

    private func setAndShowAlert(for type: WebViewType) {
        setAlertInformation(for: type)
        showAlert = true
    }

    private func setAlertInformation(for type: WebViewType) {
        alertTitle = title(for: type)
        alertMessage = errorMessage(for: type)
    }

    private func errorMessage(for type: WebViewType) -> String {
        switch type {
        case .termsAndConditons:
            "Please try again later, or contact support for immediate assistance."
        case .privatePolicy:
            "Please try again later, or contact support for immediate assistance."
        }
    }

    private func title(for type: WebViewType) -> String {
        "\(type.rawValue)"
    }
}

enum WebViewType: String {
    case termsAndConditons = "Terms and Conditions"
    case privatePolicy = "Private Policy"
}
