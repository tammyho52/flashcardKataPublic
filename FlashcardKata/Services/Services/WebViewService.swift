//
//  WebViewService.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This class manages the state of a web view for loading URLs.

import Foundation

/// A service that manages the state of a web view for displaying URLs.
@MainActor
public final class WebViewService: ObservableObject {
    // MARK: - Properties
    @Published var urlString: String?
    @Published var showWebView: Bool
    @Published var showAlert: Bool
    @Published var alertTitle: String
    @Published var alertMessage: String
    @Published var webViewURL: URL?
    
    private let allowedURLs = [
        ContentConstants.ContentStrings.privatePolicyURL,
        ContentConstants.ContentStrings.termsAndConditionsURL
    ]
    
    // MARK: - Initializer
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

    /// Loads a web view with the specified URL string and type.
    func loadWebView(urlString: String, type: WebViewType) {
        // Check if the URL is allowed
        if allowedURLs.contains(urlString),
            let url = URL(string: urlString) {
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
        case .termsAndConditions, .privatePolicy:
            "Please try again later, or contact support for immediate assistance."
        }
    }

    private func title(for type: WebViewType) -> String {
        "\(type.rawValue)"
    }
}

/// Enum representing the type of web view to display.
enum WebViewType: String {
    case termsAndConditions = "Terms and Conditions"
    case privatePolicy = "Privacy Policy"
}
