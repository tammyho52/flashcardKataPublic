//
//  SelectFlashcardsView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  View allows users to select flashcards from a list with select all & expand all features.

import SwiftUI

struct SelectFlashcardsView: View {
    @Binding var selectedDeckIDs: Set<String>
    @Binding var selectedFlashcardIDs: Set<String>
    @Binding var isLoading: Bool

    let loadDecksWithFlashcards: () async -> [(Deck, [Flashcard])]
    let sectionTitle: String

    var body: some View {
        SelectAllScreen<Deck, Flashcard>(
            selectedParentItemIDs: $selectedDeckIDs,
            selectedSubItemIDs: $selectedFlashcardIDs,
            isLoading: $isLoading,
            sectionTitle: sectionTitle,
            loadParentItemsWithSubItems: loadDecksWithFlashcards
        )
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    SelectFlashcardsView(
        selectedDeckIDs: .constant([]),
        selectedFlashcardIDs: .constant([]),
        isLoading: .constant(false),
        loadDecksWithFlashcards: { return [] },
        sectionTitle: "Review Flashcards"
    )
}
#endif
