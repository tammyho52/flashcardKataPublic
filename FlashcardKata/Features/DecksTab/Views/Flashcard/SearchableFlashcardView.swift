//
//  SearchableFlashcardView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View that displays flashcard list with a search bar for a selected deck.

import SwiftUI

struct SearchableFlashcardView: View {
    @ObservedObject var viewModel: FlashcardsListViewModel
    @State private var isSearching = false
    @State private var isLoading = false
    @State private var isLoadingAdditionalFlashcards: Bool = false
    @State private var fetchTask: Task<Void, Never>?
    @Binding var showModifyFlashcardButtons: Bool
    @Binding var isNavigationActive: Bool
    @Binding var showEditFlashcard: Bool
    @Binding var selectedFlashcardID: String?

    var selectedDeckID: String?
    let reloadData: () async -> Void
    var showSearchable: Bool
    let theme: Theme

    var body: some View {
        List {
            if viewModel.searchState == .idle {
                ForEach($viewModel.flashcards) { $flashcard in
                    FlashcardCoverView(
                        showModifyFlashardButtons: $showModifyFlashcardButtons,
                        flashcard: $flashcard,
                        theme: theme,
                        navigateToFlashcardAction: navigateToFlashcard,
                        deleteFlashcardAction: deleteFlashcard,
                        modifyFlashcardAction: modifyFlashcard
                    )
                    .id(flashcard.id)
                    .buttonStyle(.plain)
                    .onAppear {
                        if flashcard.id == viewModel.flashcards.last?.id &&
                            !viewModel.isEndOfList &&
                            !isLoadingAdditionalFlashcards {
                            isLoadingAdditionalFlashcards = true
                            fetchTask = Task {
                                if let selectedDeckID {
                                    try? await viewModel.fetchMoreFlashcards(selectedDeckID: selectedDeckID)
                                }
                                isLoadingAdditionalFlashcards = false
                            }
                        }
                    }
                }
                .padding(.top, 10)
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)
                .listRowInsets(.init(top: 5, leading: 15, bottom: 5, trailing: 15))

                if isLoadingAdditionalFlashcards {
                    Text("Loading..")
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
                    errorToast: $viewModel.searchBarErrorToast,
                    searchState: $viewModel.searchState,
                    searchResults: $viewModel.searchResults,
                    onSearchRowTap: navigateToFlashcard
                )
                .listRowSeparator(.hidden)
            }
        }
        .listStyle(.inset)
        .scrollContentBackground(.hidden)
        .applySearchable(
            searchText: $viewModel.searchText,
            showSearchable: showSearchable,
            prompt: "Search flashcards by main text"
        )
        .applyOverlayProgressScreen(isViewDisabled: $isLoading)
        .onChange(of: isSearching) { _, newValue in
            if !newValue {
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
            isLoadingAdditionalFlashcards = false
            viewModel.clearSearchText()
        }
    }

    // MARK: - Helper Methods
    private func navigateToFlashcard(_ id: String) {
        selectedFlashcardID = id
        isNavigationActive = true
    }

    private func deleteFlashcard(_ id: String) async throws {
        isLoading = true
        viewModel.flashcards.removeAll(where: { $0.id == id })
        try await viewModel.deleteFlashcard(id: id)
        await reloadData()
        isLoading = false
    }

    private func modifyFlashcard(_ id: String) {
        selectedFlashcardID = id
        showEditFlashcard = true
    }
}

#if DEBUG
#Preview {
    let viewModel: FlashcardsListViewModel = {
        let viewModel = FlashcardsListViewModel(
            searchBarManager: SearchBarManager(),
            databaseManager: MockDatabaseManager()
        )
        Task {
            await viewModel.fetchFlashcardListData(for: Deck.sampleDeck.id)
        }
        return viewModel
    }()
    return NavigationStack {
        SearchableFlashcardView(
            viewModel: viewModel,
            showModifyFlashcardButtons: .constant(true),
            isNavigationActive: .constant(false),
            showEditFlashcard: .constant(false),
            selectedFlashcardID: .constant(nil),
            selectedDeckID: nil,
            reloadData: {},
            showSearchable: true,
            theme: .blue
        )
    }
}
#endif
