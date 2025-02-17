//
//  SelectFlashcardsView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

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
