//
//  DeckCoverView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view that displays deck information within a deck list.

import SwiftUI

/// A view that displays a deck cover button with deck details and actions.
struct DeckCoverButton: View {
    // MARK: - Properties
    @Binding var showModifyDeckButtons: Bool
    @Binding var disableModifyDeckButtons: Bool

    var deck: Deck // The deck to be displayed.
    var navigateAction: () -> Void
    var removeDeckAction: () -> Void
    var editDeckAction: () -> Void
    var subdeckButtonAction: () -> Void

    // MARK: - Body
    var body: some View {
        Button(action: navigateAction) {
            VStack(alignment: .leading, spacing: 10) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        deckNameHeader
                        Spacer()
                        modifyDeckButtons
                            .frame(width: 100, alignment: .trailing)
                            .disabled(disableModifyDeckButtons)
                    }

                    VStack {
                        flashcardCountLabel
                        if !deck.isSubdeck {
                            // Shows subdeck count label only for parent decks.
                            subdeckCountLabel
                                .onTapGesture {
                                    subdeckButtonAction()
                                }
                        }
                    }
                    .padding(.bottom, 5)
                }
                .padding([.leading, .trailing, .top], DesignConstants.Padding.Content.itemInset)

                lastReviewedText
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .applyDeckCoverBackgroundGradient(
                primaryColor: deck.theme.primaryColor,
                secondaryColor: deck.theme.secondaryColor,
                isSubdeck: deck.isSubdeck
            )
            .clipDefaultShape()
            .applyCoverShadow()
        }
        .contentShape(RoundedRectangle(cornerRadius: DesignConstants.Layout.cornerRadius))
    }

    // MARK: - Helper Text Views
    private var deckNameHeader: some View {
        Text(deck.name)
            .foregroundStyle(.white)
            .font(.customHeadline)
            .fontWeight(.bold)
            .lineLimit(2, reservesSpace: true)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(5)
    }

    private var flashcardCountLabel: some View {
        Label {
            Text(formattedFlashcardCount)
        } icon: {
            Image(systemName: ContentConstants.Symbols.flashcard)
        }
        .modifier(ClearLabelTextStyle())
    }

    private var subdeckCountLabel: some View {
        Label {
            Text(formattedSubdeckCount)
        } icon: {
            Image(systemName: ContentConstants.Symbols.deck)
        }
        .modifier(ClearLabelTextStyle())
    }

    private var lastReviewedText: some View {
        Text("Last Reviewed: \(lastReviewedDateText)")
            .foregroundStyle(.black)
            .font(.customCallout)
            .fontWeight(.semibold)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DesignConstants.Padding.Content.itemInset)
            .background(.white.opacity(0.8))
    }

    // MARK: - Helper Button Views
    private var modifyDeckButtons: some View {
        HStack(spacing: 10) {
            if showModifyDeckButtons {
                editDeckButton
                    .accessibilityIdentifier("editDeckButton_\(deck.id)")
                deleteDeckButton
                    .accessibilityIdentifier("deleteDeckButton_\(deck.id)")
            }
        }
    }

    private var editDeckButton: some View {
        ModifyActionButton(
            showModifyButtons: $showModifyDeckButtons,
            action: editDeckAction,
            symbolName: "pencil.line"
        )
    }

    private var deleteDeckButton: some View {
        ModifyActionButton(
            showModifyButtons: $showModifyDeckButtons,
            action: removeDeckAction,
            symbolName: "trash"
        )
    }

    // MARK: - Computed properties
    private var lastReviewedDateText: String {
        deck.lastReviewedDate?.timeAgo() ?? "Not reviewed yet"
    }

    private var formattedFlashcardCount: String {
        pluralizeByContentWord(word: .flashcard, count: deck.flashcardCount).capitalized
    }

    private var formattedSubdeckCount: String {
        pluralizeByContentWord(word: .subdeck, count: deck.subdeckIDs.count).capitalized
    }
}

// MARK: - View Modifiers
/// A view modifier that applies a gradient background to the deck cover button.
private struct ClearLabelTextStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundStyle(.black)
            .font(.customCallout)
            .fontWeight(.semibold)
            .padding([.vertical, .trailing], 2.5)
            .padding(.leading, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.8))
            .clipShape(Capsule())
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    /// Deck with modify buttons shown.
    DeckCoverButton(
        showModifyDeckButtons: .constant(true),
        disableModifyDeckButtons: .constant(false),
        deck: Deck.sampleDeck,
        navigateAction: {}, removeDeckAction: {}, editDeckAction: {}, subdeckButtonAction: {}
    )
    .padding()

    /// Subdeck with modify buttons not shown.
    DeckCoverButton(
        showModifyDeckButtons: .constant(false),
        disableModifyDeckButtons: .constant(false),
        deck: Deck.sampleSubdeck,
        navigateAction: {}, removeDeckAction: {}, editDeckAction: {}, subdeckButtonAction: {}
    )
    .padding()
}
#endif
