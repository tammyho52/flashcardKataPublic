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

/// The landing page screen, which handles the displaying an animated app title
/// and manages transitions between authentication views (Sign Up, Login, Password Reset, User Profile).
struct LandingPageScreen: View {
    // MARK: - Properties
    @ObservedObject var viewModel: LandingPageViewModel
    @State private var viewType: LandingViewType = .title
    @State private var isTitleCentered: Bool = true // Controls animation of the app title's position.
    @State private var scaleFactor: CGFloat = 1 // Controls the scaling animation of the app title.
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                // Background image for the landing page.
                BackgroundImage(image: ContentConstants.Images.appBackgroundImage)
                    .transaction { transaction in
                        transaction.animation = nil // Removes unwanted animation effects
                    }
                    .accessibilityIdentifier("AppBackgroundImage")
                
                // The main content of the landing page.
                ScrollView {
                    VStack(spacing: 5) {
                        // Displays the app title unless in the Sign Up view.
                        if viewType != .signUp {
                            AppTitleContainerView(isTitleCentered: $isTitleCentered)
                                .scaleEffect(scaleFactor)
                                .offset(y: isTitleCentered ? 200 : 0)
                                .padding(.top, 10)
                        }
                        // Displays the view corresponding to the current view type.
                        viewForLandingPageState(viewType)
                    }
                }
            }
            .onAppear {
                startAnimations()
            }
        }
    }

    // MARK: - Private Methods
    /// Starts the animations for the app title and transitions to the login view.
    private func startAnimations() {
        // Animate the app title to move up and scale down.
        withAnimation(.easeInOut(duration: 2).delay(0.5)) {
            isTitleCentered = false
            scaleFactor = 0.8
        }
        // Transition to login view after the title animation.
        withAnimation(.easeInOut(duration: 2.5).delay(1.5)) { viewType = .login }
        // Scale the title back to its original size.
        withAnimation(.easeInOut(duration: 1.5).delay(2.5)) { scaleFactor = 1 }
    }
 
    /// Returns the appropriate view based on the current `LandingViewType`.
    /// - Parameter viewType: The current landing view type.
    /// - Returns: The corresponding view for the current state of the landing page.
    @ViewBuilder
    private func viewForLandingPageState(_ viewType: LandingViewType) -> some View {
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
    
    /// Switches to the specified view type.
    func switchToView(_ viewType: LandingViewType) {
        self.viewType.switchTo(viewType)
    }

    // MARK: - Authentication Views
    /// Sign up views allows users to create a new account.
    private var signUpView: some View {
        SignUpView(
            viewModel: viewModel,
            viewType: $viewType,
            switchToLoginScreen: { switchToView(.login) }
        )
        .padding(.top, 50) // Adjusts the padding to center the sign-up view.
    }

    /// Login view allows users to log in to their existing account.
    private var loginView: some View {
        LoginView(
            viewModel: viewModel,
            viewType: $viewType
        )
    }

    /// Password reset view allows users to reset their password.
    private var passwordResetView: some View {
        PasswordResetView(
            passwordResetAction: viewModel.sendPasswordResetEmail,
            switchToLoginScreen: { switchToView(.login) }
        )
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    let viewModel = LandingPageViewModel(
        authenticationManager: AnyAuthenticationManager.sample,
        webViewService: WebViewService()
    )
    return LandingPageScreen(viewModel: viewModel)
}
#endif
