//
//  ContentView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This view serves as the main navigation container for the FlashcardKata app once the user has logged in or is using the app in guest mode.
//  - Displays core tab views: Decks, Read, Review (Katas), Tracker, and Settings.
//  - Initializes and owns the view models for each tab.
//  - Handles cross-tab actions, such as the display of the "Add Deck" modal when triggered from any tab.
//  - Preserves tab selection state using `@SceneStorage`, maintaining user context across sessions.

import SwiftUI
import UIKit
import Combine

/// Main container view for the app's core functionalities, organizing the app's primary features into tabs.
struct HomeScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    
    /// Stores and restores the last selected tab between sessions.
    @SceneStorage("selectedTab") var selectedTab: Tab = .decks
    
    /// View model managing the Decks tab functionalities.
    @StateObject private var decksListViewModel: DecksListViewModel
    
    /// View model managing the Read tab functionalities.
    @StateObject private var readViewModel: ReadViewModel
    
    /// View model managing the Review (Katas) tab functionalities.
    @StateObject private var reviewViewModel: ReviewViewModel
    
    /// View model managing the Tracker tab functionalities.
    @StateObject private var trackerViewModel: TrackerViewModel
    
    /// View model managing the Settings tab functionalities.
    @StateObject private var settingsViewModel: SettingsViewModel
    
    @State private var showAddDeck: Bool = false
    @State private var showAddDeckFromAlternativeViews: Bool = false

    // MARK: - Initialization
    init(
        databaseManager: DatabaseManagerProtocol,
        authenticationManager: any AuthenticationManagerProtocol,
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

    // MARK: - Body
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
                    // Ensures that tapping "Add Deck" from another tab shows the modal here.
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

                ReviewOverviewScreen(viewModel: reviewViewModel, getStartedButtonAction: showAddNewDeck)
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
            .accessibilityIdentifier("tabView")
            .safeAreaInset(edge: .bottom) {
                // Adds custom tab bar to the bottom of the screen.
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

    // MARK: - Private Methods
    /// Navigates to the Decks tab and triggers the "Add Deck" modal.
    private func showAddNewDeck() {
        // If the current tab is not Decks, switch to it and show the modal.
        if selectedTab != .decks {
            Task {
                selectedTab = .decks
                await waitForTabChange()
                await MainActor.run {
                    showAddDeckFromAlternativeViews = true
                }
            }
        } else {
            // If already on Decks, just show the modal.
            showAddDeck = true
        }
    }

    /// Ensures the tab change is completed before showing the modal.
    private func waitForTabChange() async {
        while selectedTab != .decks {
            await Task.yield()
        }
    }

    /// Resets the selected tab to "Decks" when the Home Screen is dismissed (e.g. sign out).
    private func resetTab() {
        selectedTab = .decks
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    HomeScreen(
        databaseManager: MockDatabaseManager(),
        authenticationManager: FirebaseAuthenticationManager(),
        webViewService: WebViewService()
    )
}
#endif
