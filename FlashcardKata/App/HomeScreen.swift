//
//  ContentView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Centralizes tab view navigation for the App.
//  Tab displays include decks, reading, review, tracking, and settings screens.

import SwiftUI
import UIKit
import Combine

struct HomeScreen: View {
    @Environment(\.dismiss) var dismiss
    @SceneStorage("selectedTab") var selectedTab: Tab = .decks
    @StateObject var decksListViewModel: DecksListViewModel
    @StateObject var readViewModel: ReadViewModel
    @StateObject var reviewViewModel: ReviewViewModel
    @StateObject var trackerViewModel: TrackerViewModel
    @StateObject var settingsViewModel: SettingsViewModel
    @State private var showAddDeck: Bool = false
    @State private var showAddDeckFromAlternativeViews: Bool = false

    init(
        databaseManager: DatabaseManagerProtocol,
        authenticationManager: AuthenticationManager,
        webViewService: WebViewService
    ) {
        _decksListViewModel = StateObject(wrappedValue: DecksListViewModel(
            searchBarManager: SearchBarManager(),
            databaseManager: databaseManager
        ))
        _readViewModel = StateObject(wrappedValue: ReadViewModel(databaseManager: databaseManager))
        _reviewViewModel = StateObject(wrappedValue: ReviewViewModel(databaseManager: databaseManager))
        _trackerViewModel = StateObject(wrappedValue: TrackerViewModel(databaseManager: databaseManager))
        _settingsViewModel = StateObject(wrappedValue: SettingsViewModel(
            authenticationManager: authenticationManager,
            databaseManager: databaseManager,
            webViewService: webViewService
        ))
    }

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                DecksListScreen(
                    viewModel: decksListViewModel,
                    showAddDeck: $showAddDeck,
                    defaultButtonAction: showAddNewDeck
                )
                .tabItem {
                    Label("Decks", systemImage: "rectangle.on.rectangle.angled")
                }
                .tag(Tab.decks)
                .onAppear {
                    // Triggers "Add Deck" modal if triggered from different tab
                    if showAddDeckFromAlternativeViews {
                        showAddDeck = true
                        showAddDeckFromAlternativeViews = false
                    }
                }

                ReadScreen(viewModel: readViewModel, defaultButtonAction: showAddNewDeck)
                    .tabItem {
                        Label("Read", systemImage: "text.book.closed.fill")
                    }
                    .tag(Tab.read)

                ReviewOverviewScreen(viewModel: reviewViewModel, defaultButtonAction: showAddNewDeck)
                    .tabItem {
                        Label("Katas", systemImage: "timer")
                    }
                    .tag(Tab.kata)

                TrackerScreen(viewModel: trackerViewModel, defaultButtonAction: showAddNewDeck)
                    .tabItem {
                        Label("Tracker", systemImage: "calendar")
                    }
                    .tag(Tab.tracker)

                SettingsScreen(viewModel: settingsViewModel)
                    .tabItem {
                        Label("Settings", systemImage: "gearshape")
                    }
                    .tag(Tab.settings)
            }
            .safeAreaInset(edge: .bottom) {
                // Keeps custom tab bar at bottom of screen.
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
    // Navigates to the Decks tab and triggers the "Add Deck" modal
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

    // Waits for the tab to switch before showing the "Add Deck" modal.
    private func waitForTabChange() async {
        while selectedTab != .decks {
            await Task.yield()
        }
    }

    // Resets the selected tab when Home Screen disappears.
    private func resetTab() {
        selectedTab = .decks
    }
}

#if DEBUG
#Preview {
    HomeScreen(
        databaseManager: MockDatabaseManager(),
        authenticationManager: AuthenticationManager(),
        webViewService: WebViewService()
    )
}
#endif
