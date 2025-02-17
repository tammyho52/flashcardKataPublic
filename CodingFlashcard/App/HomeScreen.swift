//
//  ContentView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI
import UIKit
import Combine

struct HomeScreen: View {
    // MARK: - State and Dependencies
    @Environment(\.dismiss) var dismiss
    @SceneStorage("selectedTab") var selectedTab: Tab = .decks
    @StateObject var decksListViewModel: DecksListViewModel
    @StateObject var readViewModel: ReadViewModel
    @StateObject var reviewViewModel: ReviewViewModel
    @StateObject var trackerViewModel: TrackerViewModel
    @StateObject var settingsViewModel: SettingsViewModel
    @State var showAddDeck: Bool = false
    @State var showAddDeckFromAlternativeViews: Bool = false
 
    // MARK: - Initialization
    init(databaseManager: DatabaseManagerProtocol, authenticationManager: AuthenticationManager, webViewService: WebViewService
    ) {
        _decksListViewModel = StateObject(
            wrappedValue: DecksListViewModel(
                searchBarManager: SearchBarManager(),
                databaseManager: databaseManager
            )
        )
        _readViewModel = StateObject(
            wrappedValue: ReadViewModel(
                databaseManager: databaseManager
            )
        )
        _reviewViewModel = StateObject(
            wrappedValue: ReviewViewModel(
                databaseManager: databaseManager
            )
        )
        _trackerViewModel = StateObject(
            wrappedValue: TrackerViewModel(
                databaseManager: databaseManager
            )
        )
        _settingsViewModel = StateObject(
            wrappedValue: SettingsViewModel(
                authenticationManager: authenticationManager,
                databaseManager: databaseManager,
                webViewService: webViewService
            )
        )
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                DecksListScreen(
                    vm: decksListViewModel,
                    showAddDeck: $showAddDeck,
                    defaultButtonAction: showAddNewDeck
                )
                .tabItem {
                    Label("Decks", systemImage: "rectangle.on.rectangle.angled")
                }
                .tag(Tab.decks)
                .onAppear {
                    if showAddDeckFromAlternativeViews {
                        showAddDeck = true
                        showAddDeckFromAlternativeViews = false
                    }
                }
                
                ReadScreen(
                    vm: readViewModel,
                    defaultButtonAction: showAddNewDeck
                )
                .tabItem {
                    Label("Read", systemImage: "text.book.closed.fill")
                }
                .tag(Tab.read)
                
                ReviewOverviewScreen(
                    vm: reviewViewModel,
                    defaultButtonAction: showAddNewDeck
                )
                .tabItem {
                    Label("Katas", systemImage: "timer")
                }
                .tag(Tab.kata)
                
                TrackerScreen(vm: trackerViewModel, defaultButtonAction: showAddNewDeck)
                    .tabItem {
                        Label("Tracker", systemImage: "calendar")
                    }
                    .tag(Tab.tracker)
                
                SettingsScreen(vm: settingsViewModel)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .tag(Tab.settings)
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 0) {
                    Color.clear
                        .frame(maxHeight: .infinity)
                    CustomTabBar(selectedTab: $selectedTab)
                }
                .background(.clear)
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .onDisappear {
            resetTab()
        }
    }
    
    // MARK: - Helper Methods
    private func showAddNewDeck() {
        if selectedTab != .decks {
            Task {
                selectedTab = .decks
                await waitForTabChange()
                await MainActor.run {
                    showAddDeckFromAlternativeViews = true
                }
            }
        } else {
            showAddDeck = true
        }
    }
    
    private func waitForTabChange() async {
        while selectedTab != .decks {
            await Task.yield()
        }
    }
    
    private func resetTab() {
        selectedTab = .decks
    }
}

#if DEBUG
#Preview {
    HomeScreen(databaseManager: MockDatabaseManager(), authenticationManager: AuthenticationManager(), webViewService: WebViewService())
}
#endif
