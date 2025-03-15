//
//  SearchRow.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View to display search results based on data model type (deck, subdeck, flashcard).

import SwiftUI

struct SearchRow: View {
    var searchResultData: SearchResult
    var navigateToAction: (String) -> Void

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

    // Displays deck and subdeck search result.
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

    // Displays flashcard search result.
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

#if DEBUG
#Preview {
    SearchRow(
        searchResultData: SearchResult.mockDeck, navigateToAction: { _ in }
    )
    SearchRow(
        searchResultData: SearchResult.mockSubdeck, navigateToAction: { _ in }
    )
}

#Preview {
    SearchRow(
        searchResultData: SearchResult.longMockDeck, navigateToAction: { _ in }
    )
}

#Preview {
    List {
        SearchRow(searchResultData: SearchResult.mockFlashcard, navigateToAction: { _ in }
        )
        SearchRow(searchResultData: SearchResult.mockFlashcard, navigateToAction: { _ in }
        )
    }
}
#endif
