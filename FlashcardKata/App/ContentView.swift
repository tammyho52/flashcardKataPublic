//
//  MainView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Main view of the Flashcard Kata App.
//  Manages user authentication state and loads the appropriate screen (Home or Landing Page).

import SwiftUI

struct ContentView: View {
    @StateObject var landingPageVM: LandingPageViewModel
    @StateObject var databaseManager: DatabaseManager
    @ObservedObject var authenticationManager: AuthenticationManager
    @ObservedObject var webViewService: WebViewService
    @State private var isLoading: Bool = false

    init(authenticationManager: AuthenticationManager, webViewService: WebViewService) {
        _authenticationManager = ObservedObject(wrappedValue: authenticationManager)
        _databaseManager = StateObject(wrappedValue:
            DatabaseManager(
                deckService: DeckService(),
                flashcardService: FlashcardService(),
                reviewSessionSummaryService: ReviewSessionSummaryService(),
                authenticationManager: authenticationManager
            )
        )
        _webViewService = ObservedObject(wrappedValue: webViewService)
        _landingPageVM = StateObject(wrappedValue: LandingPageViewModel(
            authenticationManager: authenticationManager,
            webViewService: webViewService
        ))
    }

    var body: some View {
        Group {
            switch authenticationManager.authenticationState {
            case .signedIn, .guestUser:
                Group {
                    if isLoading {
                        FullScreenProgressScreen()
                    } else {
                        HomeScreen(
                            databaseManager: databaseManager,
                            authenticationManager: authenticationManager,
                            webViewService: webViewService
                        )
                    }
                }
                .onAppear {
                    // Load initial data when a signed in user enters the app
                    if authenticationManager.authenticationState == .signedIn {
                        isLoading = true
                        Task {
                            try await databaseManager.loadInitialData()
                            isLoading = false
                        }
                    }
                }
            case .signedOut:
                LandingPageScreen(viewModel: landingPageVM)
                    .transition(.slide)
            }
        }
    }
}

#if DEBUG
#Preview {
    let authenticationManager = AuthenticationManager()
    return ContentView(authenticationManager: authenticationManager, webViewService: WebViewService())
}

#Preview {
    return ContentView(authenticationManager: AuthenticationManager(), webViewService: WebViewService())
}
#endif
