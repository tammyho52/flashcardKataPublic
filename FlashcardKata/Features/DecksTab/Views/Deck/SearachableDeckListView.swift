//
//  SearachableDeckListView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View that displays deck list with a search bar.

import SwiftUI

struct SearachableDeckListView: View {
    @ObservedObject var viewModel: DecksListViewModel
    @State private var isSearching: Bool = false
    @State private var isLoading: Bool = false
    @State private var isLoadingAdditionalDecks: Bool = false
    @State private var fetchTask: Task<Void, Never>?
    @Binding var isNavigationActive: Bool
    @Binding var showEditDeck: Bool
    @Binding var showEditSubdeck: Bool
    @Binding var showModifyDeckButtons: Bool
    @Binding var selectedDeckID: String?

    let reloadData: () async -> Void
    var showSearchable: Bool

    var body: some View {
        List {
            if viewModel.searchState == .idle {
                ForEach($viewModel.decks) { $deck in
                    DeckDisclosureGroupView(
                        deck: $deck,
                        showModifyDeckButtons: $showModifyDeckButtons,
                        disableModifyDeckButtons: $isLoadingAdditionalDecks,
                        subdecks: subdecksBinding(deckID: deck.id),
                        deleteDeckAction: deleteDeck,
                        modifyDeckAction: modifyDeck,
                        navigateAction: navigateToDeck
                    )
                    .id(deck.id)
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 10, leading: 10, bottom: 10, trailing: 10))
                    .onAppear {
                        // Fetch more decks when the last deck appears.
                        if deck.id == viewModel.decks.last?.id && !viewModel.isEndOfList && !isLoadingAdditionalDecks {
                            isLoadingAdditionalDecks = true
                            fetchTask = Task {
                                try? await viewModel.fetchMoreDeckListData()
                                isLoadingAdditionalDecks = false
                            }
                        }
                    }
                }
                // Show progress view when loading additional decks.
                if isLoadingAdditionalDecks {
                    ProgressView()
                        .id(UUID()) // Uniquely identifies progress view for pagination.
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 10)
                        .listRowBackground(Color.clear)
                } else {
                    Spacer()
                        .frame(height: 5)
                        .listRowSeparator(.hidden)
                }
            } else {
                // Show search results.
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
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
        .applyOverlayProgressScreen(isViewDisabled: $isLoading)
        .applySearchable(
            searchText: $viewModel.searchText,
            showSearchable: showSearchable,
            prompt: "Search decks by name"
        )
        .onChange(of: isSearching) { _, _ in
            if !isSearching {
                viewModel.clearSearchText()
            }
        }
        .onSubmit(of: .search) {
            Task {
                await viewModel.performSearch()
            }
        }
        .onDisappear {
            fetchTask?.cancel()
            fetchTask = nil
            isLoadingAdditionalDecks = false
            viewModel.clearSearchText()
        }
    }

    // MARK: - Helper Methods
    private func subdecksBinding(deckID: String) -> Binding<[Deck]> {
        Binding(
            get: { viewModel.subdecksByDeckID[deckID] ?? [] },
            set: { viewModel.subdecksByDeckID[deckID] = $0 }
        )
    }

    private func navigateToDeck(_ id: String) {
        selectedDeckID = id
        isNavigationActive = true
    }

    private func deleteDeck(id: String) async throws {
        isLoading = true
        if let deck = try await viewModel.fetchDeck(id: id) {
            try await viewModel.deleteDeckAndAssociatedData(id: id)
            if deck.isSubdeck, let parentDeckID = deck.parentDeckID {
                viewModel.subdecksByDeckID[parentDeckID]?.removeAll(where: { $0.id == id })
            } else {
                viewModel.decks.removeAll(where: { $0.id == id })
            }
            await reloadData()
        }
        isLoading = false
    }

    private func modifyDeck(_ id: String) {
        selectedDeckID = id
        Task {
            guard let fetchedDeck = try await viewModel.fetchDeck(id: id) else { return }
            if fetchedDeck.isSubdeck {
                showEditSubdeck = true
            } else {
                showEditDeck = true
            }
        }
    }
}

#if DEBUG
#Preview {
    let viewModel: DecksListViewModel = {
        let viewModel = DecksListViewModel(
            searchBarManager: SearchBarManager(),
            databaseManager: MockDatabaseManager()
        )
        Task {
            await viewModel.fetchDeckListData()
            await viewModel.setUpSearch()
        }
        return viewModel
    }()

    NavigationStack {
        SearachableDeckListView(
            viewModel: viewModel,
            isNavigationActive: .constant(false),
            showEditDeck: .constant(false),
            showEditSubdeck: .constant(false),
            showModifyDeckButtons: .constant(false),
            selectedDeckID: .constant(nil),
            reloadData: {},
            showSearchable: true
        )
    }
}
#endif
