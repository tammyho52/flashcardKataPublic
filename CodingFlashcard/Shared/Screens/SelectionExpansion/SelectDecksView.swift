//
//  SelectDecksView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

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

#if DEBUG
#Preview {
    NavigationStack {
        SelectDecksView(selectedParentDeckIDs: .constant([]), selectedSubdeckIDs: .constant([]), isLoading: .constant(false), loadDecksWithSubdecks: { return [] }, sectionTitle: "Review Decks")
    }
}
#endif
