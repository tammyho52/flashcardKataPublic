//
//  FlashcardCardView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Displays a flashcard in a flippable format, showing the front and back of card.

import SwiftUI

struct FlashcardCardView: View {
    @Binding var showFlashcardFront: Bool
    let flashcard: Flashcard
    var isFlippable: Bool
    var showHint: Bool = true
    var showDifficultyLevel: Bool = true
    var showDeckName: Bool = true
    var deckNameLabel: DeckNameLabel
    var aspectRatio: Double

    let flashcardCornerRadius: CGFloat = 36

    var body: some View {
        Button {
            if isFlippable {
                showFlashcardFront.toggle()
            }
        } label: {
            ScrollView {
                VStack {
                    if showFlashcardFront {
                        frontText
                            .accessibilityIdentifier("flashcardFrontText")
                        if showHint && !flashcard.hint.isEmpty {
                            hintText
                        }
                        flashcardLabels
                    } else {
                        Group {
                            backText
                                .accessibilityIdentifier("flashcardBackText")
                            if !flashcard.notes.isEmpty {
                                notesText
                            }
                        }
                        .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    }
                }
            }
            .modifier(FlashcardBackground(flashcardCornerRadius: flashcardCornerRadius))
            .scrollIndicators(.hidden)
        }
        .accessibilityElement(children: .ignore)
        .buttonStyle(.plain)
        .contentShape(RoundedRectangle(cornerRadius: flashcardCornerRadius))
        .clipShape(RoundedRectangle(cornerRadius: flashcardCornerRadius))
        .aspectRatio(aspectRatio, contentMode: .fit)
        .applyCoverShadow()
        .onTapGesture {
            withAnimation {
                showFlashcardFront.toggle()
            }
        }
        .rotation3DEffect(showFlashcardFront ? .degrees(0) : .degrees(180), axis: (x: 0, y: 1, z: 0))
        .animation(.default, value: showFlashcardFront)
    }

    private var frontText: some View {
        LabeledBodyText(flashcardTextType: .frontText(flashcard.frontText))
    }

    private var hintText: some View {
        LabeledBodyText(flashcardTextType: .hint(flashcard.hint))
    }

    private var flashcardLabels: some View {
        FlashcardTagsDisplay(
            showDifficultyLevel: showDifficultyLevel,
            showDeckName: showDeckName,
            difficultyLevel: flashcard.difficultyLevel,
            deckNameLabel: deckNameLabel
        )
    }

    private var backText: some View {
        LabeledBodyText(flashcardTextType: .backText(flashcard.backText))
    }

    private var notesText: some View {
        LabeledBodyText(flashcardTextType: .notes(flashcard.notes))
    }

    private struct FlashcardBackground: ViewModifier {
        let flashcardCornerRadius: CGFloat

        func body(content: Content) -> some View {
            content
                .padding(5)
                .background(LinearGradient(
                    colors: [.white, Color.customBackground.opacity(0.5)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ))
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .overlay {
                    RoundedRectangle(cornerRadius: flashcardCornerRadius)
                        .stroke(Color.customAccent.opacity(0.8), lineWidth: 2)
                        .applyCoverShadow()
                }
                .padding(12.5)
                .background(.white)
        }
    }
}

extension FlashcardCardView {
    init(
        showFlashcardFront: Binding<Bool>,
        isFlippable: Bool,
        flashcard: Flashcard,
        reviewSettings: ReviewSettings = ReviewSettings(
            showHint: true,
            showDifficultyLevel: true,
            showFlashcardDeckName: true
        ),
        deckNameLabel: DeckNameLabel,
        aspectRatio: Double = 0.65
    ) {
        self._showFlashcardFront = showFlashcardFront
        self.isFlippable = isFlippable
        self.flashcard = flashcard
        self.showHint = reviewSettings.showHint
        self.showDifficultyLevel = reviewSettings.showDifficultyLevel
        self.showDeckName = reviewSettings.showFlashcardDeckName
        self.deckNameLabel = deckNameLabel
        self.aspectRatio = aspectRatio
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    FlashcardCardView(
        showFlashcardFront: .constant(true),
        isFlippable: true,
        flashcard: Flashcard.sampleFlashcard,
        deckNameLabel: DeckNameLabel.sample
    )
}

#Preview {
    FlashcardCardView(
        showFlashcardFront: .constant(false),
        isFlippable: false,
        flashcard: Flashcard.sampleFlashcard,
        deckNameLabel: DeckNameLabel.sample
    )
}
#endif
