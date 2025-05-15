//
//  MainView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Main entry view for the Flashcard Kata App.
//  - Manages app navigation based on user authentication state.
//  - Initializes the appropriate DatabaseManager (mock or real) based on build configuration.
//  - Displays the Home Screen for authenticated users and guest users with limited functionality, or the Landing Page for unauthenticated users.
//  - Preloads user data upon signing in.

import SwiftUI

/// Main view of the Flashcard Kata app.
///
/// Determines whether the user is signed in or not and displays the appropriate screen.
/// Initializes supporting services and view models (e.g. database manager, landing page view model)
/// and ensures testing environments receive mocked dependencies where needed.
struct ContentView: View {
    // MARK: - Properties
    /// View model for handling the landing page logic and interactions.
    @StateObject private var landingPageVM: LandingPageViewModel
    
    /// Database manager abstraction, configured with real or mock database manager.
    @StateObject private var databaseManager: AnyDatabaseManager
    
    /// Authentication manager abstraction to handle user authentication state.
    @ObservedObject var authenticationManager: AnyAuthenticationManager
    
    /// Web view service abstraction to manage web view interactions.
    @ObservedObject var webViewService: WebViewService
    
    /// State variable to indicate whether the app is loading data.
    @MainActor @State private var isLoading: Bool = false

    // MARK: - Initializer
    init(
        authenticationManager: AnyAuthenticationManager,
        webViewService: WebViewService
    ) {
        _authenticationManager = ObservedObject(wrappedValue: authenticationManager)
        _webViewService = ObservedObject(wrappedValue: webViewService)
        
        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-UITesting") {
            // Inject mock database manager for UI testing
            _databaseManager = StateObject(wrappedValue:
                AnyDatabaseManager(databaseManager:
                    MockDatabaseManager()
                )
            )
        } else {
            // Inject real database manager for development
            _databaseManager = StateObject(wrappedValue:
                AnyDatabaseManager(databaseManager:
                    DatabaseManager(
                        deckService: DeckService(),
                        flashcardService: FlashcardService(),
                        reviewSessionSummaryService: ReviewSessionSummaryService(),
                        authenticationManager: authenticationManager
                    )
                )
            )
        }
        #else
        // Inject real database manager for production
        _databaseManager = StateObject(wrappedValue:
            AnyDatabaseManager(databaseManager:
                DatabaseManager(
                    deckService: DeckService(),
                    flashcardService: FlashcardService(),
                    reviewSessionSummaryService: ReviewSessionSummaryService(),
                    authenticationManager: authenticationManager
                )
            )
        )
        #endif
    
        _landingPageVM = StateObject(wrappedValue: LandingPageViewModel(
            authenticationManager: authenticationManager,
            webViewService: webViewService
        ))
    }

    // MARK: - Body
    var body: some View {
        Group {
            switch authenticationManager.authenticationState {
            case .signedIn, .guestUser:
                // Show the home screen for signed in users and guest users (with limited functionality)
                SignedInOrGuestView(
                    isLoading: $isLoading,
                    databaseManager: databaseManager,
                    authenticationManager: authenticationManager,
                    webViewService: webViewService
                )
                .onAppear {
                    loadInitialDataIfSignedIn()
                }
            case .signedOut:
                // Show the landing page for unauthenticated users
                LandingPageScreen(viewModel: landingPageVM)
                    .transition(.slide)
            }
        }
    }
    
    // MARK: - Private Methods
    /// Automatically loads initial data when the signed in user returns
    private func loadInitialDataIfSignedIn() {
        if authenticationManager.authenticationState == .signedIn {
            isLoading = true
            Task {
                defer { isLoading = false }
                do {
                    try await databaseManager.loadInitialData()
                } catch {
                    reportError(error)
                }
            }
        }
    }
}

// MARK: - SignedInOrGuestView
/// Displays the home screen for signed in users and guest users (with limited functionality).
private struct SignedInOrGuestView: View {
    @Binding var isLoading: Bool
    var databaseManager: AnyDatabaseManager
    var authenticationManager: AnyAuthenticationManager
    var webViewService: WebViewService
    
    var body: some View {
        Group {
            if isLoading {
                FullScreenProgressScreen()
                    .edgesIgnoringSafeArea(.bottom)
            } else {
                HomeScreen(
                    databaseManager: databaseManager,
                    authenticationManager: authenticationManager,
                    webViewService: webViewService
                )
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    return ContentView(
        authenticationManager: AnyAuthenticationManager.sample,
        webViewService: WebViewService()
    )
}
#endif
