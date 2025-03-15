//
//  LandingPageView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Landing page of the App.
//  Displays an animated app title and manages transitions between
//  authentication views (Sign Up, Login, Password Reset, User Profile).

import SwiftUI

struct LandingPageScreen: View {
    @ObservedObject var viewModel: LandingPageViewModel
    @State private var isTitleCentered: Bool = true
    @State private var viewType: LandingViewType = .title
    @State private var scaleFactor: CGFloat = 1

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundImage(image: ContentConstants.Images.appBackgroundImage)
                    .transaction { transaction in
                        transaction.animation = nil // Removes unwanted animation effects
                    }
                ScrollView {
                    VStack(spacing: 5) {
                        if viewType != .signUp {
                            AppTitleContainerView(isTitleCentered: $isTitleCentered)
                                .scaleEffect(scaleFactor)
                                .offset(y: isTitleCentered ? 200 : 0)
                                .padding(.top, 10)
                        }
                        viewForType(viewType)
                    }
                }
            }
            .onAppear {
                startAnimations()
            }
        }
    }

    // MARK: - Helper Methods
    // Animates the title movement and transitions to the login view.
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2).delay(0.5)) {
            isTitleCentered = false
            scaleFactor = 0.8
        }
        withAnimation(.easeInOut(duration: 2.5).delay(1.5)) { viewType = .login }
        withAnimation(.easeInOut(duration: 1.5).delay(2.5)) { scaleFactor = 1 }
    }

    // Returns the appropriate view based on the current `LandingViewType`.
    @ViewBuilder
    private func viewForType(_ viewType: LandingViewType) -> some View {
        switch viewType {
        case .title:
            EmptyView()
        case .signUp:
            signUpView
        case .login:
            loginView
        case .passwordReset:
            passwordResetView
        case .userProfile:
            EmptyView()
        }
    }

    // Updates the current view type.
    func switchToView(_ viewType: LandingViewType) {
        self.viewType.switchTo(viewType)
    }

    // MARK: - Authentication Views
    private var signUpView: some View {
        SignUpView(
            viewModel: viewModel,
            viewType: $viewType,
            switchToLoginScreen: { switchToView(.login) }
        )
        .padding(.top, 50) // Center the view from the top, while other views include the app title at top.
    }

    private var loginView: some View {
        LoginView(
            viewModel: viewModel,
            viewType: $viewType
        )
    }

    private var passwordResetView: some View {
        PasswordResetView(
            passwordResetAction: viewModel.sendPasswordResetEmail,
            switchToLoginScreen: { switchToView(.login) }
        )
    }
}

#if DEBUG
#Preview {
    let viewModel = LandingPageViewModel(
        authenticationManager: AuthenticationManager(),
        webViewService: WebViewService()
    )
    return LandingPageScreen(viewModel: viewModel)
}
#endif
