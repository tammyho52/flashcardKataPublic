//
//  MainView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct ContentView: View {
    // MARK: - State Management and Dependencies
    @StateObject var vm: LandingPageViewModel
    @StateObject var databaseManager: DatabaseManager
    @ObservedObject var authenticationManager: AuthenticationManager
    @ObservedObject var webViewService: WebViewService
    @State var isLoading: Bool = false
    
    // MARK: - Initialization
    init(authenticationManager: AuthenticationManager, webViewService: WebViewService) {
        _authenticationManager = ObservedObject(wrappedValue: authenticationManager)
        _databaseManager = StateObject(wrappedValue: DatabaseManager(deckService: DeckService(), flashcardService: FlashcardService(), reviewSessionSummaryService: ReviewSessionSummaryService(), authenticationManager: authenticationManager))
        _webViewService = ObservedObject(wrappedValue: webViewService)
        _vm = StateObject(wrappedValue: LandingPageViewModel(authenticationManager: authenticationManager, webViewService: webViewService))
    }
    
    // MARK: - Body
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
                    if authenticationManager.authenticationState == .signedIn {
                        isLoading = true
                        Task {
                            try await databaseManager.loadInitialData()
                            isLoading = false
                        }
                    }
                }
            case .signedOut:
                LandingPageScreen(vm: vm)
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
