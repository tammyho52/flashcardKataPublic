//
//  SettingsScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View displays navigation to general and account settings.

import SwiftUI

struct SettingsScreen: View {
    @ObservedObject var viewModel: SettingsViewModel
    @State private var activeSheet: ActiveSheet?
    @State private var showDeleteAccountAlert: Bool = false
    @State private var webViewType: WebViewType = .termsAndConditons

    let privatePolicyURLString: String = ContentConstants.ContentStrings.privatePolicyURL
    let termsAndConditionsURLString: String = ContentConstants.ContentStrings.termsAndConditionsURL

    var body: some View {
        NavigationStack {
            List {
                Section {
                    helpCenterButton
                    rateUsButton
                    termsAndConditionsButton
                    privacyPolicyButton
                } header: {
                    Text("General")
                        .font(.customHeadline)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                }
                .headerProminence(.increased)
                .listRowSeparatorTint(.black)

                Section {
                    if viewModel.isGuestUser() {
                        signUpAndLoginButton
                    } else {
                        // Additional fields to show if user is logged in via email/password.
                        if viewModel.authenticationProvider == .emailPassword {
                            updatePasswordButton
                            updateEmailButton
                        }
                        signOutButton
                        deleteAccountButton
                    }
                } header: {
                    Text("Account")
                        .font(.customHeadline)
                        .fontWeight(.bold)
                        .padding(.top, 10)
                }
                .headerProminence(.increased)
                .listRowSeparatorTint(.black)
            }
            .listRowSpacing(0)
            .listStyle(.insetGrouped)
            .listSectionSpacing(0)
            .navigationTitle("Settings")
            .scrollContentBackground(.hidden)
            .applyColoredNavigationBarStyle(backgroundGradientColors: Tab.settings.backgroundGradientColors)
            .alert(isPresented: $showDeleteAccountAlert) {
                deleteAccountAlert()
            }
            .webViewAlert(
                isPresented: $viewModel.showWebViewAlert,
                title: viewModel.alertTitle,
                message: viewModel.alertMessage,
                dismissAction: viewModel.dismissWebView
            )
        }
        .sheet(isPresented: $viewModel.showWebView) {
            if let url = viewModel.webViewURL {
                WebView(
                    url: url,
                    onFinishedLoading: nil,
                    onError: nil
                )
            }
        }
        // Shows active sheet based on user interaction.
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .updatePassword:
                PasswordUpdateScreen(sendPasswordEmail: viewModel.sendPasswordResetEmail)
            case .emailReset:
                EmailUpdateScreen(viewModel: viewModel)
            case .reauthentication:
                ReauthenticationScreen(
                    buttonAction: { email, password in
                        Task {
                            do {
                                try await viewModel.reauthenticateUser(email: email, password: password) {
                                    activeSheet = nil
                                    do {
                                        try await viewModel.deleteUserData()
                                        try await viewModel.deleteUser()
                                    } catch {
                                        activeSheet = nil
                                    }
                                }
                            } catch {
                                activeSheet = nil
                            }
                        }
                    }
                )
            case .helpCenter:
                NavigationStack {
                    HelpCenterView()
                }
            }
        }
    }

    // MARK: - Helper Methods
    private func signOut() async throws {
        try await viewModel.signOut()
    }

    private func deleteAccountAlert() -> Alert {
        Alert(
            title: Text("Delete Account?"),
            message: Text("This action cannot be undone. Are you sure you want to delete your account?"),
            primaryButton: .destructive(Text("Delete")) {
                Task {
                    if let authenticationProvider = viewModel.authenticationProvider {
                        switch authenticationProvider {
                        // Show email/password reauthentication view before proceeding with account deletion.
                        case .emailPassword:
                            activeSheet = .reauthentication
                        // Show third-party reauthentication view before proceeding with account deletion.
                        case .google, .apple:
                            do {
                                try await viewModel.reauthenticateUser(email: nil, password: nil) {
                                    do {
                                        try await viewModel.deleteUserData()
                                        try await viewModel.deleteUser()
                                    } catch {
                                        showDeleteAccountAlert = false
                                    }
                                }
                            } catch {
                                showDeleteAccountAlert = false
                            }
                        // This should never trigger for guest.
                        case .guest:
                            return
                        }
                    }
                    showDeleteAccountAlert = false
                }
            },
            secondaryButton: .cancel {
                showDeleteAccountAlert = false
            }
        )
    }

    // MARK: - List Row Buttons
    var helpCenterButton: some View {
        SettingsListRow(
            action: {
                activeSheet = .helpCenter
            },
            title: "Help Center",
            symbol: ContentConstants.Symbols.helpCenter
        )
        .buttonStyle(.plain)
    }

    var termsAndConditionsButton: some View {
        SettingsListRow(
            action: {
                webViewType = .termsAndConditons
                viewModel.loadWebView(urlString: termsAndConditionsURLString, type: webViewType)
            },
            title: "Terms & Conditions",
            symbol: ContentConstants.Symbols.termsAndConditions
        )
        .buttonStyle(.plain)
    }

    var privacyPolicyButton: some View {
        SettingsListRow(
            action: {
                webViewType = .privatePolicy
                viewModel.loadWebView(urlString: privatePolicyURLString, type: webViewType)
            },
            title: "Privacy Policy",
            symbol: ContentConstants.Symbols.privatePolicy
        )
        .buttonStyle(.plain)
    }

    var rateUsButton: some View {
        SettingsListRow(
            action: {
                requestAppReview()
            },
            title: "Rate Us",
            symbol: ContentConstants.Symbols.rateUs
        )
        .buttonStyle(.plain)
    }

    var signUpAndLoginButton: some View {
        SettingsListRow(
            action: {
                viewModel.navigateToSignInWithoutAccount()
            },
            title: "Sign Up & Login",
            symbol: ContentConstants.Symbols.signUpAndLogin
        )
        .buttonStyle(.plain)
    }

    var updatePasswordButton: some View {
        SettingsListRow(
            action: {
                activeSheet = .updatePassword
            },
            title: "Update Password",
            symbol: SignInSignUpField.password.symbol
        )
        .buttonStyle(.plain)
    }

    var updateEmailButton: some View {
        SettingsListRow(
            action: {
                activeSheet = .emailReset
            },
            title: "Update Email",
            symbol: SignInSignUpField.email.symbol
        )
        .buttonStyle(.plain)
    }

    var signOutButton: some View {
        SettingsListRow(
            action: signOut,
            title: "Sign Out",
            symbol: ContentConstants.Symbols.signOut
        )
    }

    var deleteAccountButton: some View {
        SettingsListRow(
            action: {
                showDeleteAccountAlert = true
            },
            title: "Delete Account",
            symbol: ContentConstants.Symbols.deleteAccount,
            role: .destructive
        )
    }
}

// Controls active modal sheet for view
private enum ActiveSheet: String, Identifiable {
    case helpCenter
    case reauthentication
    case updatePassword
    case emailReset

    var id: String {
        return self.rawValue
    }
}

#if DEBUG
#Preview {
    SettingsScreen(
        viewModel: SettingsViewModel(
            authenticationManager: AuthenticationManager(),
            databaseManager: MockDatabaseManager(),
            webViewService: WebViewService()
        )
    )
}
#endif
