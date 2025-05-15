//
//  DeckFormView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View for creating and modifying decks, including subdeck management.

import SwiftUI

/// A view that provides a form for creating or modifying a deck, including subdeck management.
struct DeckFormView: View {
    // MARK: - Properties
    @State private var subdeckName: SubdeckName = SubdeckName() // Tracks the name of a new subdeck being added.
    @Binding var deck: Deck // The parent deck being created or modified.
    @Binding var subdeckNames: [SubdeckName] // The list of subdeck names associated with the deck.
    @Binding var isSaveButtonDisabled: Bool
    
    var saveButtonTitle: String // Allows customization of the button title.
    var saveButtonAction: () -> Void
    let isEditView: Bool // Indicates whether the view is in edit mode or create mode.
    
    // MARK: - Body
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                // Displays the main deck and allows adding subdecks.
                AddDecksDisplay(
                    deck: $deck,
                    newSubdeckName: $subdeckName,
                    subdeckNames: $subdeckNames
                )
                
                // Displays the list of subdecks and allows editing or removing them.
                AddSubDecksDisplay(
                    subdecksNames: $subdeckNames,
                    isEditView: isEditView
                )
                .padding(.bottom, 20)
                
                // Save button for creating or modifying the deck.
                DeckFormButton(
                    isDisabled: $isSaveButtonDisabled,
                    title: saveButtonTitle,
                    action: saveButtonAction
                )
            }
            .padding(.horizontal)
        }
        .scrollDismissesKeyboard(.immediately)
    }
}

/// A button used in the deck form for saving or performing other actions.
private struct DeckFormButton: View {
    @Binding var isDisabled: Bool
    var title: String
    var action: () -> Void

    var body: some View {
        Button(title) {
            action()
        }
        .padding(.vertical, 7.5)
        .padding(.horizontal, 25)
        .fontWeight(.semibold)
        .foregroundStyle(.white)
        .background(isDisabled ? Color(.systemGray6) : Color.customSecondary)
        .clipShape(Capsule())
        .disabled(isDisabled)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    NavigationStack {
        DeckFormView(
            deck: .constant(Deck()),
            subdeckNames: .constant([]),
            isSaveButtonDisabled: .constant(false),
            saveButtonTitle: "Create Deck",
            saveButtonAction: {},
            isEditView: true
        )
    }
}
#endif
