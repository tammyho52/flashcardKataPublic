//
//  TermsAndConditionsAgreementView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Displays the legal agreement text with tappable links to
//  legal agreements (Terms and Conditions, Privacy Policy).

import SwiftUI

/// A view that presents legal agreement text with tappable links to the Terms and Conditions and Privacy Policy.
struct LegalAgreementTextWithWebLink: View {
    // MARK: - Properties
    @ObservedObject var viewModel: LandingPageViewModel

    // MARK: - Body
    var body: some View {
        // Displays legal agreement text with tappable links.
        VStack(alignment: .leading, spacing: 5) {
            Text("By continuing, you agree to our ")
            HStack(spacing: 0) {
                termsAndConditionsLink
                Text(" and ")
            }
            HStack(spacing: 0) {
                privacyPolicyLink
                Text(".")
            }
        }
        .sheet(isPresented: $viewModel.showWebView) {
            // Show WebView to the legal agreements in-app when a legal link is tapped.
            if let url = viewModel.webViewURL {
                NavigationStack {
                    VStack {
                        WebView(
                            url: url,
                            onError: viewModel.handleWebViewError
                        )
                        .navigationTitle("Legal Agreement")
                    }
                }
            }
        }
        .webViewAlert(
            isPresented: $viewModel.showWebViewAlert,
            title: viewModel.alertTitle,
            message: viewModel.alertMessage,
            dismissAction: viewModel.dismissWebView
        )
    }

    // MARK: - Legal Agreement Link Views
    private var termsAndConditionsLink: some View {
        TappableLink(
            text: "Terms and Conditions",
            action: viewModel.loadTermsAndConditionsWebView
        )
    }

    private var privacyPolicyLink: some View {
        TappableLink(
            text: "Privacy Policy",
            action: viewModel.loadPrivacyPolicyWebView
        )
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    LegalAgreementTextWithWebLink(
        viewModel: LandingPageViewModel(
            authenticationManager: AnyAuthenticationManager.sample,
            webViewService: WebViewService()
        )
    )
}
#endif
