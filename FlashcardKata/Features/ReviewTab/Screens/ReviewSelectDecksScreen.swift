//
//  ReviewSelectDecksScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view for selecting decks before starting the review session, including parent and subdecks.

import SwiftUI

/// A view for selecting decks to include in the review session.
struct ReviewSelectDecksScreen: View {
    // MARK: - Properties
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ReviewViewModel
    @State private var selectedParentDeckIDs: Set<String> = []
    @State private var selectedSubdeckIDs: Set<String> = []
    @State private var isLoading = false
    @State private var errorToast: Toast?
    @State private var showSelectFlashcardsView: Bool = false
    @Binding var showSelectDecksView: Bool

    var combinedSelectedDeckIDs: Set<String> {
        selectedParentDeckIDs.union(selectedSubdeckIDs)
    }

    // MARK: - Body
    var body: some View {
        NavigationStack {
            SelectDecksView(
                selectedParentDeckIDs: $selectedParentDeckIDs,
                selectedSubdeckIDs: $selectedSubdeckIDs,
                isLoading: $isLoading,
                loadDecksWithSubdecks: loadDecksWithSubdecks,
                sectionTitle: "Review Decks"
            )
            .accessibilityIdentifier("selectReviewDecksView")
            .navigationTitle("Deck Selection")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .applyOverlayProgressScreen(isViewDisabled: $isLoading)
            .navigationDestination(isPresented: $showSelectFlashcardsView) {
                ReviewSelectFlashcardsScreen(
                    viewModel: viewModel,
                    showSelectDecksView: $showSelectDecksView,
                    showSelectFlashcardsView: $showSelectFlashcardsView,
                    previousSelectedDeckIDs: combinedSelectedDeckIDs
                )
            }
            .addToast(toast: $errorToast)
            .toolbar {
                toolbarExitButton(isDisabled: isLoading) {
                    dismiss()
                }

                toolbarNextButton(isDisabled: isLoading) {
                    showSelectFlashcardsView = true
                }
            }
            .applyClearNavigationBarStyle()
        }
    }

    // MARK: - Private Methods
    /// Loads the parent decks with their respective subdecks.
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
    ReviewSelectDecksScreen(
        viewModel: ReviewViewModel(databaseManager: MockDatabaseManager()),
        showSelectDecksView: .constant(true)
    )
}
#endif
