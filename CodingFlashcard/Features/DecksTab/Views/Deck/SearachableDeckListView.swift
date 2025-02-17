//
//  SearachableDeckListView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct SearachableDeckListView: View {
    @ObservedObject var vm: DecksListViewModel
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
            if vm.searchState == .idle {
                ForEach($vm.decks) { $deck in
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
                        if deck.id == vm.decks.last?.id && !vm.isEndOfList && !isLoadingAdditionalDecks {
                            isLoadingAdditionalDecks = true
                            fetchTask = Task {
                                try? await vm.fetchMoreDeckListData()
                                isLoadingAdditionalDecks = false
                            }
                        }
                    }
                }
                
                if isLoadingAdditionalDecks {
                    ProgressView()
                        .id(UUID())
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 10)
                        .listRowBackground(Color.clear)
                } else {
                    Spacer()
                        .frame(height: 5)
                        .listRowSeparator(.hidden)
                }
            } else {
                SearchResultsScreen(
                    errorToast: $vm.searchBarErrorToast,
                    searchState: $vm.searchState,
                    searchResults: $vm.searchResults,
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
        .applySearchable(searchText: $vm.searchText, showSearchable: showSearchable, prompt: "Search decks by name")
        .onChange(of: isSearching) { _, newValue in
            if !isSearching {
                vm.clearSearchText()
            }
        }
        .onSubmit(of: .search) {
            Task {
                await vm.performSearch()
            }
        }
        .onDisappear {
            fetchTask?.cancel()
            fetchTask = nil
            isLoadingAdditionalDecks = false
            vm.clearSearchText()
        }
    }
    
    // MARK: - Helper Methods
    
    private func subdecksBinding(deckID: String) -> Binding<[Deck]> {
        Binding(
            get: { vm.subdecksByDeckID[deckID] ?? [] },
            set: { vm.subdecksByDeckID[deckID] = $0 }
        )
    }

    private func navigateToDeck(_ id: String) {
        selectedDeckID = id
        isNavigationActive = true
    }

    private func deleteDeck(id: String) async throws {
        isLoading = true
        if let deck = try await vm.fetchDeck(id: id) {
            try await vm.deleteDeckAndAssociatedData(id: id)
            if deck.isSubdeck, let parentDeckID = deck.parentDeckID {
                vm.subdecksByDeckID[parentDeckID]?.removeAll(where: { $0.id == id })
            } else {
                vm.decks.removeAll(where: { $0.id == id })
            }
            await reloadData()
        }
        isLoading = false
    }
    
    private func modifyDeck(_ id: String) {
        selectedDeckID = id
        Task {
            guard let fetchedDeck = try await vm.fetchDeck(id: id) else { return }
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
    let vm: DecksListViewModel = {
        let vm = DecksListViewModel(searchBarManager: SearchBarManager(), databaseManager: MockDatabaseManager())
        Task {
            await vm.fetchDeckListData()
            await vm.setUpSearch()
        }
        return vm
    }()
    
    NavigationStack {
        SearachableDeckListView(
            vm: vm,
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
