//
//  SelectDecksView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  View allows users to select decks and subdecks from a list with select all & expand all features.

import SwiftUI

struct SelectDecksView: View {
    @Binding var selectedParentDeckIDs: Set<String>
    @Binding var selectedSubdeckIDs: Set<String>
    @Binding var isLoading: Bool

    let loadDecksWithSubdecks: () async -> [(Deck, [Deck])]

    let sectionTitle: String

    var body: some View {
        SelectAllScreen<Deck, Deck>(
            selectedParentItemIDs: $selectedParentDeckIDs,
            selectedSubItemIDs: $selectedSubdeckIDs,
            isLoading: $isLoading,
            sectionTitle: sectionTitle,
            loadParentItemsWithSubItems: loadDecksWithSubdecks
        )
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    NavigationStack {
        SelectDecksView(
            selectedParentDeckIDs: .constant([]),
            selectedSubdeckIDs: .constant([]),
            isLoading: .constant(false),
            loadDecksWithSubdecks: { return [] },
            sectionTitle: "Review Decks"
        )
    }
}
#endif
