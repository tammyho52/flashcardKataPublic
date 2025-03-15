//
//  TermsAndConditionsAgreementView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Displays the legal agreement text with tappable links to legal agreements (Terms and Conditions, Private Policy).

import SwiftUI

struct LegalAgreementTextWithWebLink: View {
    @ObservedObject var viewModel: LandingPageViewModel

    var authenticationProvider: AuthenticationProvider?

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("By continuing, you agree to our ")
            HStack(spacing: 0) {
                termsAndConditionsText
                Text(" and ")
            }
            HStack(spacing: 0) {
                privatePolicyText
                Text(".")
            }
        }
        .sheet(isPresented: $viewModel.showWebView) {
            // Show WebView when a legal link is tapped.
            if let url = viewModel.webViewURL {
                WebView(
                    url: url,
                    onFinishedLoading: nil,
                    onError: viewModel.handleWebViewError
                )
            }
        }
        .webViewAlert(
            isPresented: $viewModel.showWebViewAlert,
            title: viewModel.alertTitle,
            message: viewModel.alertMessage,
            dismissAction: viewModel.dismissWebView
        )
    }

    // MARK: - Tappable Links to Legal Agreements
    private var termsAndConditionsText: some View {
        TappableLink(
            text: "Terms and Conditions",
            action: viewModel.loadTermsAndConditionsWebView
        )
    }

    private var privatePolicyText: some View {
        TappableLink(
            text: "Private Policy",
            action: viewModel.loadPrivacyPolicyWebView
        )
    }
}

#if DEBUG
#Preview {
    LegalAgreementTextWithWebLink(
        viewModel: LandingPageViewModel(
            authenticationManager: AuthenticationManager(),
            webViewService: WebViewService()
        )
    )
}
#endif
