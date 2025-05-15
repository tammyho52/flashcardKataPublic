//
//  LegalAgreementView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Displays legal agreement text and handles user consent
//  before initiating third-party authentication (e.g. Apple, Google).

import SwiftUI

/// A view that presents legal agreements and manages user consent before triggering third-party authentication.
struct LegalAgreementView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: LandingPageViewModel
    @MainActor @State private var isLoading: Bool = false
    @MainActor @State private var errorToast: Toast?
    @Binding var showLegalAgreementView: Bool
    
    let authenticationProvider: AuthenticationProvider

    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            dismissButton
            
            VStack(spacing: 50) {
                // Displays agreement text with tappable legal links.
                LegalAgreementTextWithWebLink(viewModel: viewModel)
                    .frame(maxWidth: .infinity, alignment: .center)

                // Continue sign-in process with third-party authentication.
                continueButton
            }
        }
        .standardSectionStyle()
        .applyOverlayProgressScreen(isViewDisabled: $isLoading)
    }
    
    // MARK: - Helper Views
    private var dismissButton: some View {
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
    }
    
    /// A button that allows the user to continue with third-party authentication.
    private var continueButton: some View {
        PrimaryButton(
            isDisabled: false,
            text: "Continue",
            action: {
                isLoading = true
                
                // Handle sign-in process based on the selected authentication provider.
                switch authenticationProvider {
                case .google:
                    Task {
                        defer { isLoading = false }
                        try await googleSignInAction()
                    }
                case .apple:
                    Task {
                        defer { isLoading = false }
                        try await appleSignInAction()
                    }
                default:
                    // For unsupported authentication providers, dismiss the view.
                    withAnimation {
                        defer { isLoading = false }
                        showLegalAgreementView = false
                    }
                }
            }
        )
    }

    // MARK: - Sign In Actions
    /// Handles Google sign-in process.
    private func googleSignInAction() async throws {
        do {
            try await viewModel.handleGoogleSignInAndSignUp()
        } catch {
            updateErrorToast(error, errorToast: $errorToast)
            reportError(error)
        }
    }
    
    /// Handles Apple sign-in process.
    private func appleSignInAction() async throws {
        do {
            try await viewModel.handleAppleSignInAndSignUp()
        } catch {
            updateErrorToast(error, errorToast: $errorToast)
            reportError(error)
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    LegalAgreementView(viewModel: LandingPageViewModel(
        authenticationManager: AnyAuthenticationManager.sample,
        webViewService: WebViewService()),
        showLegalAgreementView: .constant(true),
        authenticationProvider: .apple
    )
}
#endif
