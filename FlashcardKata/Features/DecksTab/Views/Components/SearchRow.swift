//
//  SearchRow.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A reusable view for displaying search results based on the type of data model (deck, subdeck, flashcard).

import SwiftUI

/// A view that represents a single search result row, adaptable to search result type (deck, subdeck, flashcard).
struct SearchRow: View {
    // MARK: - Properties
    var searchResultData: SearchResult // The data model representing the search result.
    var navigateToAction: (String) -> Void // The action to perform when the row is tapped.

    // MARK: - Body
    var body: some View {
        Button {
            navigateToAction(searchResultData.id)
        } label: {
            switch searchResultData.searchResultType {
            case .deck, .subdeck:
                deckSearchRow
            case .flashcard:
                flashcardSearchRow
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Helper Views
    /// A view for displaying search results of type `deck` or `subdeck`.
    var deckSearchRow: some View {
        HStack(alignment: .top) {
            Text(searchResultData.title)
                .frame(maxWidth: .infinity, alignment: .leading)
                .multilineTextAlignment(.leading)
            Text(searchResultData.subTitle)
                .frame(width: 100)
                .padding(5)
                .foregroundStyle(.white)
                .applyDeckCoverBackgroundGradient(
                    primaryColor: searchResultData.theme.primaryColor,
                    secondaryColor: searchResultData.theme.secondaryColor,
                    isSubdeck: searchResultData.searchResultType == .subdeck
                )
                .clipDefaultShape()
        }
        .fontWeight(searchResultData.searchResultType == .subdeck ? .semibold : .bold)
        .padding(.leading, searchResultData.searchResultType == .subdeck ? 20 : 0)
        .contentShape(Rectangle())
    }

    /// A view for displaying search results of type `flashcard`.
    var flashcardSearchRow: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(searchResultData.subTitle)
                .lineLimit(2)
                .fontWeight(.semibold)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .foregroundStyle(.white)
                .applyDeckCoverBackgroundGradient(
                    primaryColor: searchResultData.theme.primaryColor,
                    secondaryColor: searchResultData.theme.secondaryColor,
                    isSubdeck: searchResultData.searchResultType == .subdeck
                )
                .clipDefaultShape()

            Text(searchResultData.title)
                .fontWeight(.semibold)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
    }

}

// MARK: - Preview
#if DEBUG
/// Preview for deck and subdeck search results.
#Preview {
    SearchRow(
        searchResultData: SearchResult.sampleDeck, navigateToAction: { _ in }
    )
    SearchRow(
        searchResultData: SearchResult.sampleSubdeck, navigateToAction: { _ in }
    )
}

/// Preview for long deck search results.
#Preview {
    SearchRow(
        searchResultData: SearchResult.longSampleDeck, navigateToAction: { _ in }
    )
}

/// Preview for flashcard search results.
#Preview {
    List {
        SearchRow(searchResultData: SearchResult.sampleFlashcard, navigateToAction: { _ in }
        )
        SearchRow(searchResultData: SearchResult.sampleFlashcard, navigateToAction: { _ in }
        )
    }
}
#endif
