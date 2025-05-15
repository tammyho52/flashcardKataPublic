//
//  SettingsScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  This view provides navigation to general and account settings

import SwiftUI

/// A view that displays the settings for the app, including general settings, account settings, and options to access help center, rate the app, and view terms and conditions and privacy policy.
struct SettingsScreen: View {
    // MARK: - Properties
    @ObservedObject var viewModel: SettingsViewModel
    @State private var activeSheet: ActiveSheet?
    @State private var showDeleteAccountAlert: Bool = false
    @State private var webViewType: WebViewType = .termsAndConditions

    // MARK: - Constants
    let privatePolicyURLString: String = ContentConstants.ContentStrings.privatePolicyURL
    let termsAndConditionsURLString: String = ContentConstants.ContentStrings.termsAndConditionsURL
    
    // MARK: - Body
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
                        // Show sign up and login button if user is a guest.
                        signUpAndLoginButton
                    } else {
                        // Show update password and email buttons if user is logged in via email/password.
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
                                    do {
                                        try await viewModel.deleteUserData()
                                        try await viewModel.deleteUser()
                                        activeSheet = nil
                                    } catch {
                                        activeSheet = nil
                                        reportError(error)
                                    }
                                }
                            } catch {
                                activeSheet = nil
                                reportError(error)
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

    // MARK: - Private Methods and Alerts
    private func signOut() async throws {
        try await viewModel.signOut()
    }

    /// Creates an alert to confirm account deletion.
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
                                        reportError(error)
                                    }
                                }
                            } catch {
                                showDeleteAccountAlert = false
                                reportError(error)
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

    // MARK: - Private Buttons
    private var helpCenterButton: some View {
        SettingsListRow(
            action: {
                activeSheet = .helpCenter
            },
            title: "Help Center",
            symbol: ContentConstants.Symbols.helpCenter
        )
        .buttonStyle(.plain)
    }

    private var termsAndConditionsButton: some View {
        SettingsListRow(
            action: {
                webViewType = .termsAndConditions
                viewModel.loadWebView(urlString: termsAndConditionsURLString, type: webViewType)
            },
            title: "Terms & Conditions",
            symbol: ContentConstants.Symbols.termsAndConditions
        )
        .buttonStyle(.plain)
    }

    private var privacyPolicyButton: some View {
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

    private var rateUsButton: some View {
        SettingsListRow(
            action: {
                requestAppReview()
            },
            title: "Rate Us",
            symbol: ContentConstants.Symbols.rateUs
        )
        .buttonStyle(.plain)
    }

    private var signUpAndLoginButton: some View {
        SettingsListRow(
            action: {
                viewModel.navigateToSignInWithoutAccount()
            },
            title: "Sign Up & Login",
            symbol: ContentConstants.Symbols.signUpAndLogin
        )
        .buttonStyle(.plain)
    }

    private var updatePasswordButton: some View {
        SettingsListRow(
            action: {
                activeSheet = .updatePassword
            },
            title: "Update Password",
            symbol: SignInSignUpField.password.symbol
        )
        .buttonStyle(.plain)
    }

    private var updateEmailButton: some View {
        SettingsListRow(
            action: {
                activeSheet = .emailReset
            },
            title: "Update Email",
            symbol: SignInSignUpField.email.symbol
        )
        .buttonStyle(.plain)
    }

    private var signOutButton: some View {
        SettingsListRow(
            action: signOut,
            title: "Sign Out",
            symbol: ContentConstants.Symbols.signOut
        )
    }

    private var deleteAccountButton: some View {
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

// MARK: - Active Sheet Enum
/// Enum that controls the active modal sheet for settings screen, if any.
private enum ActiveSheet: String, Identifiable {
    case helpCenter
    case reauthentication
    case updatePassword
    case emailReset

    var id: String {
        return self.rawValue
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    SettingsScreen(
        viewModel: SettingsViewModel(
            authenticationManager: FirebaseAuthenticationManager(),
            databaseManager: MockDatabaseManager(),
            webViewService: WebViewService()
        )
    )
}
#endif
