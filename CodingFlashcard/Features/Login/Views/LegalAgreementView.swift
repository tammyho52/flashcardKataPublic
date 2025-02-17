//
//  LegalAgreementView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct LegalAgreementView: View {
    @ObservedObject var vm: LandingPageViewModel
    @State private var isLoading: Bool = false
    @Binding var showLegalAgreementView: Bool
    
    let authenticationProvider: AuthenticationProvider
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
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
                LegalAgreementTextWithWebLink(vm: vm)
                    .frame(maxWidth: .infinity, alignment: .center)
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
    
    private func googleSignInAction() async throws {
        try await vm.handleGoogleSignInAndSignUp()
    }
    
    private func appleSignInAction() async throws {
        try await vm.handleAppleSignInAndSignUp()
    }
}

#Preview {
    LegalAgreementView(vm: LandingPageViewModel(authenticationManager: AuthenticationManager(), webViewService: WebViewService()),  showLegalAgreementView: .constant(true), authenticationProvider: .apple)
}
