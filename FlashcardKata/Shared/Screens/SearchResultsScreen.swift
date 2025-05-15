//
//  DeckSearchResultsView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Displays different views based on search state.

import SwiftUI

struct SearchResultsScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @Binding var errorToast: Toast?
    @Binding var searchState: SearchState
    @Binding var searchResults: [SearchResult]

    var onSearchRowTap: (String) -> Void

    var body: some View {
        switch searchState {
        case .idle:
            EmptyView()
        case .loading:
            OverlayProgressScreen()
        case .noResults:
            ContentUnavailableView.search
        case .error:
            // Replicate an EmptyView while allowing for Toast.
            Text("")
                .addToast(toast: $errorToast)
        case .resultsFound:
            searchResultsView
        }
    }

    var searchResultsView: some View {
        ForEach(searchResults, id: \.id) { searchResultData in
            SearchRow(
                searchResultData: searchResultData,
                navigateToAction: onSearchRowTap
            )
            Divider()
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    SearchResultsScreen(
        errorToast: .constant(nil),
        searchState: .constant(.resultsFound),
        searchResults: .constant([
            SearchResult(deck: Deck.sampleDeckArray[0]),
            SearchResult(deck: Deck.sampleDeckArray[1])
        ]),
        onSearchRowTap: { _ in }
    )
}

#Preview {
    SearchResultsScreen(
        errorToast: .constant(nil),
        searchState: .constant(.resultsFound),
        searchResults: .constant([
            SearchResult(flashcard: Flashcard.sampleFlashcardArray[0], deckName: Deck.sampleDeck.name, theme: .blue),
            SearchResult(flashcard: Flashcard.sampleFlashcardArray[1], deckName: Deck.sampleDeck.name, theme: .blue)
        ]),
        onSearchRowTap: { _ in }
    )
}

#Preview {
    SearchResultsScreen(
        errorToast: .constant(Toast(
            style: .warning,
            message: "Search results are unavailable at this time. Please try again later.",
            position: .top
        )),
        searchState: .constant(.error),
        searchResults: .constant([]),
        onSearchRowTap: { _ in }
    )
}
#endif
