//
//  ReadSelectDecksScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view for selecting decks and subdecks for the Read screen.

import SwiftUI

/// A view for selecting decks and subdecks for reading.
struct ReadSelectDecksScreen: View {
    // MARK: - Properties
    @ObservedObject var viewModel: ReadViewModel
    @State private var selectedParentDeckIDs: Set<String> = []
    @State private var selectedSubdeckIDs: Set<String> = []
    @State private var isLoading = false
    @State private var errorToast: Toast?
    @State private var showSelectFlashcardsView: Bool = false
    @Binding var selectedFlashcardIDs: Set<String>
    @Binding var showSelectDeckView: Bool
    
    var combinedSelectedDeckIDs: Set<String> {
        selectedParentDeckIDs.union(selectedSubdeckIDs)
    }
    
    // MARK: - Body
    var body: some View {
        SelectDecksView(
            selectedParentDeckIDs: $selectedParentDeckIDs,
            selectedSubdeckIDs: $selectedSubdeckIDs,
            isLoading: $isLoading,
            loadDecksWithSubdecks: loadDecksWithSubdecks,
            sectionTitle: "Read Decks"
        )
        .navigationTitle("Deck Selection")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .applyOverlayProgressScreen(isViewDisabled: $isLoading)
        .navigationDestination(isPresented: $showSelectFlashcardsView) {
            ReadSelectFlashcardsScreen(
                viewModel: viewModel,
                selectedFlashcardIDs: $selectedFlashcardIDs,
                showSelectDecksView: $showSelectDeckView,
                showSelectFlashcardsView: $showSelectFlashcardsView,
                previousSelectedDeckIDs: combinedSelectedDeckIDs
            )
        }
        .addToast(toast: $errorToast)
        .toolbar {
            toolbarBackButton(isDisabled: isLoading) {
                showSelectDeckView = false
            }

            toolbarNextButton(isDisabled: isLoading) {
                showSelectFlashcardsView = true
            }
        }
    }
    
    // MARK: - Private Methods
    private func loadDecksWithSubdecks() async -> [(Deck, [Deck])] {
        do {
            return try await viewModel.loadParentDecksWithSubDecks()
        } catch {
            updateErrorToast(error, errorToast: $errorToast)
            reportError(error)
        }
        return []
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    NavigationStack {
        ReadSelectDecksScreen(
            viewModel: ReadViewModel(databaseManager: MockDatabaseManager()),
            selectedFlashcardIDs: .constant(Set(Flashcard.sampleFlashcardArray.map { $0.id })),
            showSelectDeckView: .constant(true)
        )
    }
    .font(.customBody)
}
#endif
