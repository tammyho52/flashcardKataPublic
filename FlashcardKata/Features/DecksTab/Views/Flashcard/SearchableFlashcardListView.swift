//
//  SearchableFlashcardView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View that displays a list of flashcards with a search bar for a selected deck.

import SwiftUI

/// A view that displays a searchable list of flashcards for a selected deck with functionality for navigating, modifying, and deleting flashcards.
struct SearchableFlashcardListView: View {
    // MARK: - Properties
    @ObservedObject var viewModel: FlashcardsListViewModel
    @State private var isSearching = false
    @MainActor @State private var isLoading: Bool = false
    @MainActor @State private var isLoadingAdditionalFlashcards: Bool = false // Tracks if additional flashcards are being loaded.
    @State private var showDeleteAlert: Bool = false
    @State private var errorToast: Toast?
    @Binding var showModifyFlashcardButtons: Bool // Toggles the visibility of modify flashcard buttons.
    @Binding var isNavigationActive: Bool
    @Binding var showEditFlashcard: Bool
    @Binding var selectedFlashcardID: String? // Tracks the ID of the selected flashcard.
    
    let reloadData: () async -> Void
    let theme: Theme // The deck theme used for styling the flashcard list.

    var body: some View {
        List {
            // Displays the flashcard list when not searching.
            if viewModel.searchState == .idle {
                ForEach($viewModel.flashcards, id: \.id) { $flashcard in
                    FlashcardCoverView(
                        showDeleteAlert: $showDeleteAlert,
                        showModifyFlashardButtons: $showModifyFlashcardButtons,
                        flashcard: $flashcard,
                        theme: theme,
                        navigateToFlashcardAction: navigateToFlashcard,
                        deleteFlashcardAction: deleteFlashcard,
                        modifyFlashcardAction: modifyFlashcard
                    )
                    .accessibilityIdentifier("flashcardCoverView_\(flashcard.id)")
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(.init(top: 5, leading: 15, bottom: 5, trailing: 15))
                    .task(id: flashcard.id) {
                        // Loads additional flashcards when the user scrolls to the end of the list.
                        if flashcard.id == viewModel.flashcards.last?.id
                            && !viewModel.isEndOfList
                            && !isLoadingAdditionalFlashcards
                        {
                            isLoadingAdditionalFlashcards = true
                            await viewModel.fetchMoreFlashcards()
                            isLoadingAdditionalFlashcards = false
                        }
                    }
                }
                
                // Displays a loading indicator when additional flashcards are being loaded.
                if isLoadingAdditionalFlashcards {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 10)
                        .id("ProgressView")
                }
            } else {
                // Displays search results when searching.
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
        .padding(.bottom, 10)
        .scrollContentBackground(.hidden)
        .addToast(toast: $errorToast)
        .applySearchable(
            searchText: $viewModel.searchText,
            prompt: "Search flashcards by main text"
        )
        .applyOverlayProgressScreen(isViewDisabled: $isLoading)
        .accessibilityIdentifier("flashcardListScreenWithData")
        .onChange(of: isSearching) { _, newValue in
            // Clears the search text when the user stops searching.
            if !newValue {
                viewModel.clearSearchText()
            }
        }
        .onSubmit(of: .search) {
            // Performs the search when the user submits the search query.
            Task {
                await viewModel.performSearch()
            }
        }
        .onDisappear {
            // Resets the loading state and clears the search text when the view disappears.
            isLoadingAdditionalFlashcards = false
            viewModel.clearSearchText()
        }
    }

    // MARK: - Private Methods
    /// Navigates to the selected flashcard.
    private func navigateToFlashcard(_ id: String) {
        selectedFlashcardID = id
        isNavigationActive = true
    }
    
    /// Deletes the specified flashcard and refreshes the data.
    private func deleteFlashcard(_ id: String) {
        isLoading = true
        viewModel.flashcards.removeAll(where: { $0.id == id })
        Task {
            defer {
                isLoading = false
                showDeleteAlert = false
            }
            do {
                try await viewModel.deleteFlashcard(id: id)
                await reloadData()
            } catch {
                updateErrorToast(error, errorToast: $errorToast)
                reportError(error)
            }
        }
    }
    
    /// Shows the edit flashcard screen for the specified flashcard.
    private func modifyFlashcard(_ id: String) {
        selectedFlashcardID = id
        showEditFlashcard = true
    }
}

// MARK: - Preview
#if DEBUG
// Preview with sample data and hide modify buttons
#Preview {
    let viewModel: FlashcardsListViewModel = {
        let viewModel = FlashcardsListViewModel(
            searchBarManager: SearchBarManager(),
            databaseManager: MockDatabaseManager()
        )
        viewModel.flashcards = Flashcard.sampleFlashcardArray
        return viewModel
    }()
    return NavigationStack {
        SearchableFlashcardListView(
            viewModel: viewModel,
            showModifyFlashcardButtons: .constant(false),
            isNavigationActive: .constant(false),
            showEditFlashcard: .constant(false),
            selectedFlashcardID: .constant(nil),
            reloadData: {},
            theme: .blue
        )
    }
}

// Preview with no flashcards and show modify buttons
#Preview {
    let viewModel: FlashcardsListViewModel = {
        let viewModel = FlashcardsListViewModel(
            searchBarManager: SearchBarManager(),
            databaseManager: EmptyMockDatabaseManager()
        )
        return viewModel
    }()
    return NavigationStack {
        SearchableFlashcardListView(
            viewModel: viewModel,
            showModifyFlashcardButtons: .constant(true),
            isNavigationActive: .constant(false),
            showEditFlashcard: .constant(false),
            selectedFlashcardID: .constant(nil),
            reloadData: {},
            theme: .blue
        )
    }
}
#endif
