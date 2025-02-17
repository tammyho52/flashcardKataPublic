//
//  SettingsScreen.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct SettingsScreen: View {
    @ObservedObject var vm: SettingsViewModel
    @State var showHelpCenterView: Bool = false
    @State var showUpdatePasswordView: Bool = false
    @State var showDeleteAccountAlert: Bool = false
    @State var showReauthenticationView: Bool = false
    @State var showEmailResetSheet: Bool = false
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
                    if vm.isGuestUser() {
                        signUpAndLoginButton
                    } else {
                        if vm.authenticationProvider == .emailPassword {
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
            .alert("Delete Account?", isPresented: $showDeleteAccountAlert,
                actions: {
                    Button("Delete", role: .destructive) {
                        Task {
                            if let authenticationProvider = vm.authenticationProvider {
                                switch authenticationProvider {
                                case .emailPassword:
                                    showReauthenticationView = true
                                case .google, .apple:
                                    do {
                                        try await vm.reauthenticateUser(email: nil, password: nil) {
                                            do {
                                                try await vm.deleteUserData()
                                                try await vm.deleteUser()
                                            } catch {
                                                showDeleteAccountAlert = false
                                            }
                                        }
                                    } catch {
                                        showDeleteAccountAlert = false
                                    }
                                case .guest:
                                    showDeleteAccountAlert = false
                                }
                            }
                            showDeleteAccountAlert = false
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        showDeleteAccountAlert = false
                    }
                },
                message: {
                    Text("This action cannot be undone. Are you sure you want to delete your account?")
                }
            )
            .webViewAlert(
                isPresented: $vm.showWebViewAlert,
                title: vm.alertTitle,
                message: vm.alertMessage,
                dismissAction: vm.dismissWebView
            )
        }
        .sheet(isPresented: $showUpdatePasswordView) {
            PasswordUpdateScreen(sendPasswordEmail: vm.sendPasswordResetEmail)
        }
        .sheet(isPresented: $showEmailResetSheet) {
            EmailUpdateScreen(vm: vm)
        }
        .sheet(isPresented: $showReauthenticationView) {
            ReauthenticationScreen(
                showReauthenticationView: $showReauthenticationView,
                buttonAction: { email, password in
                    Task {
                        do {
                            try await vm.reauthenticateUser(email: email, password: password) {
                                showReauthenticationView = false
                                do {
                                    try await vm.deleteUserData()
                                    try await vm.deleteUser()
                                } catch {
                                    showReauthenticationView = false
                                }
                            }
                        } catch {
                            showReauthenticationView = false
                        }
                    }
                })
        }
        .sheet(isPresented: $showHelpCenterView) {
            NavigationStack {
                HelpCenterView()
            }
        }
        .sheet(isPresented: $vm.showWebView) {
            if let url = vm.webViewURL {
                WebView(
                    url: url,
                    onFinishedLoading: nil,
                    onError: nil
                )
            }
        }
    }
   
    private func signOut() async throws {
        try await vm.signOut()
    }
    
    var helpCenterButton: some View {
        SettingsListRow(
            action: {
                showHelpCenterView = true
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
                vm.loadWebView(urlString: termsAndConditionsURLString, type: webViewType)
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
                vm.loadWebView(urlString: privatePolicyURLString, type: webViewType)
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
                vm.navigateToSignInWithoutAccount()
            },
            title: "Sign Up & Login",
            symbol: ContentConstants.Symbols.signUpAndLogin
        )
        .buttonStyle(.plain)
    }
    
    var updatePasswordButton: some View {
        SettingsListRow(
            action: {
                showUpdatePasswordView = true
            },
            title: "Update Password",
            symbol: SignInSignUpField.password.symbol
        )
        .buttonStyle(.plain)
    }
    
    var updateEmailButton: some View {
        SettingsListRow(
            action: {
                showEmailResetSheet = true
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

#if DEBUG
#Preview {
    SettingsScreen(vm: SettingsViewModel(authenticationManager: AuthenticationManager(), databaseManager: MockDatabaseManager(), webViewService: WebViewService()))
}
#endif
