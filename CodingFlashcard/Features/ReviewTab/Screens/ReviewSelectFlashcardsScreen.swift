//
//  ReviewSelectFlashcardsScreen.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct ReviewSelectFlashcardsScreen: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: ReviewViewModel
    @State private var selectedDeckIDs: Set<String> = []
    @State private var selectedFlashcardIDs: Set<String> = []
    @State private var isLoading = false
    @State private var errorToast: Toast?
    @Binding var showSelectDecksView: Bool
    @Binding var showSelectFlashcardsView: Bool
    
    let previousSelectedDeckIDs: Set<String>
    
    var body: some View {
        SelectFlashcardsView(
            selectedDeckIDs: $selectedDeckIDs,
            selectedFlashcardIDs: $selectedFlashcardIDs,
            isLoading: $isLoading,
            loadDecksWithFlashcards: loadDecksWithFlashcards,
            sectionTitle: "Review Flashcards"
        )
        .navigationTitle("Flashcard Selection")
        .toolbarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .applyOverlayProgressScreen(isViewDisabled: $isLoading)
        .addToast(toast: $errorToast)
        .toolbar {
            toolbarBackButton(isDisabled: isLoading) {
                showSelectFlashcardsView = false
            }
            toolbarTextButton(
                isDisabled: isLoading,
                action: {
                    vm.reviewSettings.selectedFlashcardIDs = selectedFlashcardIDs
                    showSelectFlashcardsView = false
                    showSelectDecksView = false
                },
                text: "Done",
                placement: .topBarTrailing
            )
        }
    }
    
    private func loadDecksWithFlashcards() async -> [(Deck, [Flashcard])] {
        do {
            return try await vm.loadDecksWithFlashcards(deckIDs: previousSelectedDeckIDs)
        } catch {
            errorToast = Toast(style: .warning, message: "Unable to select flashcards at this time. Please try again later.")
        }
        return []
    }
}

#if DEBUG
#Preview {
    let deckIDs: [String] = Deck.sampleDeckArray.map(\.id)
    let subdeckIDs: [String] = Deck.sampleSubdeckArray.map(\.id)
    let combinedDeckIDs = deckIDs + subdeckIDs
    
    ReviewSelectFlashcardsScreen(vm: ReviewViewModel(databaseManager: MockDatabaseManager()), showSelectDecksView: .constant(false), showSelectFlashcardsView: .constant(false), previousSelectedDeckIDs: Set(combinedDeckIDs))
}
#endif
