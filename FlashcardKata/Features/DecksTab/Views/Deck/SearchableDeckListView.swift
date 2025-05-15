//
//  SearchableDeckListView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Displays a searchable list of decks and subdecks.

import SwiftUI

/// A view that displays a list of decks and subdecks with search functionality.
struct SearchableDeckListView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: DecksListViewModel
    @State private var isSearching: Bool = false // Tracks if the user is currently searching
    @MainActor @State private var isLoading: Bool = false // Tracks if the view is loading data
    @MainActor @State private var isLoadingAdditionalDecks: Bool = false // Tracks if more decks are being loaded at the end of the deck list
    @MainActor @State private var errorToast: Toast?
    @Binding var isNavigationActive: Bool
    @Binding var showModifyDeckButtons: Bool // Toggles the visibility of modify deck buttons
    @Binding var selectedDeckID: String?
    @MainActor @Binding var showEditDeck: Bool
    @MainActor @Binding var showEditSubdeck: Bool

    let reloadData: () async -> Void
    
    // MARK: - Body
    var body: some View {
        List {
            // Deck list view when not searching
            if viewModel.searchState == .idle {
                ForEach($viewModel.deckWithSubdecks, id: \.parentDeck.id) { $deckWithSubdeck in
                    DeckDisclosureGroupView(
                        deck: $deckWithSubdeck.parentDeck,
                        showModifyDeckButtons: $showModifyDeckButtons,
                        disableModifyDeckButtons: $isLoadingAdditionalDecks,
                        subdecks: $deckWithSubdeck.subdecks,
                        deleteDeckAction: deleteDeck,
                        modifyDeckAction: modifyDeck,
                        navigateAction: navigateToDeck
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 10, leading: 10, bottom: 10, trailing: 10))
                    .listSectionSeparator(.hidden)
                    .task(id: deckWithSubdeck.parentDeck.id) {
                        if deckWithSubdeck.parentDeck.id == viewModel.deckWithSubdecks.last?.parentDeck.id
                            && !viewModel.isEndOfList
                            && !isLoadingAdditionalDecks
                        {
                            isLoadingAdditionalDecks = true
                            await viewModel.fetchMoreDecksWithSubdecks()
                            isLoadingAdditionalDecks = false
                        }
                    }
                }
                // Loads additional decks when the user scrolls to the end of the list
                if isLoadingAdditionalDecks {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 10)
                        .id("ProgressView")
                }
            // Search results view when searching
            } else {
                SearchResultsScreen(
                    errorToast: $viewModel.searchBarErrorToast,
                    searchState: $viewModel.searchState,
                    searchResults: $viewModel.searchResults,
                    onSearchRowTap: navigateToDeck
                )
                .listSectionSeparator(.hidden)
                .listRowSeparator(.hidden)
            }
        }
        .padding(.horizontal, 5)
        .padding(.bottom, 10)
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
        .applyOverlayProgressScreen(isViewDisabled: $isLoading)
        .addToast(toast: $errorToast)
        .applySearchable(
            searchText: $viewModel.searchText,
            prompt: "Search decks by name"
        )
        .onChange(of: isSearching) { _, _ in
            // When the user stops searching, clear the search text
            if !isSearching {
                viewModel.clearSearchText()
            }
        }
        .onSubmit(of: .search) {
            // When the user submits the search, perform the search
            Task {
                await viewModel.performSearch()
            }
        }
        .onDisappear {
            // When the view disappears, reset the loading state and clear the search text
            isLoadingAdditionalDecks = false
            viewModel.clearSearchText()
        }
    }

    // MARK: - Private Methods
    /// Navigates to the selected deck.
    private func navigateToDeck(_ id: String) {
        selectedDeckID = id
        isNavigationActive = true
    }
    
    /// Deletes the specified deck and its associated data.
    private func deleteDeck(id: String) {
        isLoading = true
        guard let deck = viewModel.allDecks.first(where: { $0.id == id }) else {
            return
        }
        // Perform deletion if the deck is a subdeck
        if deck.isSubdeck,
           let parentDeckID = deck.parentDeckID,
           let index = viewModel.deckWithSubdecks.firstIndex(where: { $0.parentDeck.id == parentDeckID })
        {
            viewModel.deckWithSubdecks[index].subdecks.removeAll(where: { $0.id == id })
        // If the deck is a parent deck, remove it from the list of decks
        } else {
            viewModel.deckWithSubdecks.removeAll(where: { $0.parentDeck.id == id })
        }
        Task {
            defer {
                isLoading = false
            }
            do {
                try await viewModel.deleteDeckAndAssociatedData(id: id)
                await reloadData()
            } catch {
                updateErrorToast(error, errorToast: $errorToast)
                reportError(error)
            }
        }
    }
    
    /// Shows the edit deck screen for the specified deck.
    private func modifyDeck(_ id: String) {
        selectedDeckID = id
        Task {
            guard let fetchedDeck = try await viewModel.fetchDeck(id: id) else {
                errorToast = Toast(style: .error, message: "Cannot fetch deck.")
                return
            }
            if fetchedDeck.isSubdeck {
                showEditSubdeck = true
            } else {
                showEditDeck = true
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    let databaseManager = AnyDatabaseManager(databaseManager: MockDatabaseManager())
    let viewModel: DecksListViewModel = {
        let viewModel = DecksListViewModel(
            searchBarManager: SearchBarManager(),
            databaseManager: databaseManager
        )
        Task {
            await viewModel.fetchInitialDecksWithSubdecks()
            await viewModel.setUpSearch()
        }
        return viewModel
    }()

    NavigationStack {
        SearchableDeckListView(
            viewModel: viewModel,
            isNavigationActive: .constant(false),
            showModifyDeckButtons: .constant(false),
            selectedDeckID: .constant(nil),
            showEditDeck: .constant(false),
            showEditSubdeck: .constant(false),
            reloadData: {}
        )
    }
}
#endif
