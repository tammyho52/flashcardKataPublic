//
//  LegalAgreementView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Presents legal agreement to users before proceeding with third-party authentication.

import SwiftUI

struct LegalAgreementView: View {
    @ObservedObject var viewModel: LandingPageViewModel
    @State private var isLoading: Bool = false
    @Binding var showLegalAgreementView: Bool

    let authenticationProvider: AuthenticationProvider

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                // Dismisses legal agreement view.
                Button {
                    withAnimation {
                        showLegalAgreementView = false
                    }
                } label: {
                    Image(systemName: "x.circle.fill")
                        .font(.title)
                        .foregroundStyle(Color.customAccent)
                        .fontWeight(.bold)
                }
                Spacer()
            }
            VStack(spacing: 50) {
                // Displays legal agreement text as tappable links.
                LegalAgreementTextWithWebLink(viewModel: viewModel)
                    .frame(maxWidth: .infinity, alignment: .center)

                // Proceed with third-party authentication process after agreeing to legal agreements.
                PrimaryButton(
                    isDisabled: false,
                    text: "Continue",
                    action: {
                        isLoading = true
                        switch authenticationProvider {
                        case .google:
                            Task {
                                try await googleSignInAction()
                                isLoading = false
                            }
                        case .apple:
                            Task {
                                try await appleSignInAction()
                                isLoading = false
                            }
                        default:
                            withAnimation {
                                showLegalAgreementView = false
                                isLoading = false
                            }
                        }
                    }
                )
            }
        }
        .standardSectionStyle()
        .applyOverlayProgressScreen(isViewDisabled: $isLoading)
    }

    // MARK: - Navigate to Third-Party Authentication
    private func googleSignInAction() async throws {
        try await viewModel.handleGoogleSignInAndSignUp()
    }

    private func appleSignInAction() async throws {
        try await viewModel.handleAppleSignInAndSignUp()
    }
}

#Preview {
    LegalAgreementView(viewModel: LandingPageViewModel(
        authenticationManager: AuthenticationManager(),
        webViewService: WebViewService()),
        showLegalAgreementView: .constant(true),
        authenticationProvider: .apple
    )
}
