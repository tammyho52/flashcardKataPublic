//
//  LandingPageView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.

import SwiftUI

struct LandingPageScreen: View {
    // MARK: - State and Dependencies
    @ObservedObject var vm: LandingPageViewModel
    @State var isTitleCentered: Bool = true
    @State var viewType: LandingViewType = .title
    @State var scaleFactor: CGFloat = 1
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundImage(image: ContentConstants.Images.appBackgroundImage)
                    .transaction { transaction in
                        transaction.animation = nil // Removes applied animation
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
    
    // MARK: - Helper Functions
    private func startAnimations() {
        // Animate title movement and scaling
        withAnimation(.easeInOut(duration: 2).delay(0.5)) {
            isTitleCentered = false
            scaleFactor = 0.8
        }
        
        // Transition to login view after a delay
        withAnimation(.easeInOut(duration: 2.5).delay(1.5)) {
            viewType = .login
        }
        
        // Reset scale factor after the transition
        withAnimation(.easeInOut(duration: 1.5).delay(2.5)) {
            scaleFactor = 1
        }
    }
    
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
    
    func switchToView(_ viewType: LandingViewType) {
        self.viewType.switchTo(viewType)
    }
    
    // MARK: - Child Views
    private var signUpView: some View {
        SignUpView(
            vm: vm,
            viewType: $viewType,
            switchToLoginScreen: { switchToView(.login) }
        )
        .padding(.top, 50)
    }
    
    private var loginView: some View {
        LoginView(
            vm: vm,
            viewType: $viewType
        )
    }
    
    private var passwordResetView: some View {
        PasswordResetView(
            passwordResetAction: vm.sendPasswordResetEmail,
            switchToLoginScreen: { switchToView(.login) }
        )
    }
}

#if DEBUG
#Preview {
    let vm = LandingPageViewModel(
        authenticationManager: AuthenticationManager(),
        webViewService: WebViewService()
    )
    
    return LandingPageScreen(vm: vm)
}
#endif
