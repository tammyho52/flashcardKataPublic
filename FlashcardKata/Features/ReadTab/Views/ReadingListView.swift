//
//  ReadingListView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view to display a horizontal scrollable list of flashcards for an engaging reading experience.

import SwiftUI

/// A view that displays a horizontal list of flashcards with customizable layouts and options.
struct ReadingListView: View {
    // MARK: - Properties
    @State private var frameWidth: CGFloat = 0 // The width of the frame for layout calculations.
    @State private var isEndOfDeck: Bool = false // Indicates if the end of the deck is reached.
    @State private var lastFlashcardID: String? // Stores the ID of the last flashcard to trigger end of deck flag.
    @State private var showFlippableFlashcardFront = true // For front only layout
    @State private var showStaticFlashcardFront = true // For front and back layout
    @State private var showStaticFlashcardBack = false // For front and back layout
    @Binding var flashcardLayout: FlashcardLayout
    @Binding var flashcardDisplayModels: [FlashcardDisplayModel]
    
    var showHint: Bool
    var showDifficultyLevel: Bool
    var showDeckName: Bool

    // MARK: - Constants
    let cardSpacing: CGFloat = 30 // Spacing between cards

    // MARK: - Body
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [GridItem()], spacing: cardSpacing) {
                ForEach(flashcardDisplayModels, id: \.flashcard.id) { flashcardDisplayModel in
                    flashcardCardView(for: flashcardDisplayModel)
                        .accessibilityIdentifier("readFlashcard")
                        .padding(.vertical, 5)
                        .overlay(alignment: .bottom) {
                            // Displays the end of deck label if the last flashcard is reached
                            if flashcardDisplayModel.flashcard.id == lastFlashcardID {
                                endOfDeckLabel
                                    .padding(.vertical, 20)
                            }
                        }
                        .visualEffect { content, proxy in
                            // Applies a 3D rotation effect to the flashcards as they scroll.
                            content
                                .rotation3DEffect(
                                    .degrees(-proxy.frame(in: .global).minX + cardSpacing) / 8,
                                    axis: (x: 0, y: 1, z: 0)
                                )
                        }
                }
            }
            .padding(.horizontal, cardSpacing)
            .padding(.bottom, 30)
            .scrollTargetLayout()
            .accessibilityElement(children: .contain)
        }
        .accessibilityIdentifier("readTabScreen")
        .scrollTargetBehavior(.viewAligned)
        .overlay {
            ViewGeometry()
        }
        .onPreferenceChange(ViewSizeKey.self) { size in
            frameWidth = max(size.width, 0) // Updates frame width for layout calculations.
        }
        .onAppear {
            lastFlashcardID = flashcardDisplayModels.last?.flashcard.id
        }
        .onChange(of: flashcardDisplayModels) {
            lastFlashcardID = flashcardDisplayModels.last?.flashcard.id
        }
    }

    // MARK: - Helper Views
    /// Displays the flashcard view based on the selected layout.
    @ViewBuilder
    private func flashcardCardView(for flashcardDisplayModel: FlashcardDisplayModel) -> some View {
        if flashcardLayout == .frontOnly {
            // Front only layout: Displays the front side of the flashcard with option to flip the flashcard to view back side.
            FlashcardReadingView(
                showFlashcardFront: $showFlippableFlashcardFront,
                flashcardDisplayModel: flashcardDisplayModel,
                showHint: showHint,
                showDifficultyLevel: showDifficultyLevel,
                showDeckName: showDeckName,
                frameWidth: max(0, frameWidth - (cardSpacing * 2))
            )
        } else {
            // Front and back layout: Displays both sides of the flashcard with no flipping option.
            VStack(spacing: 20) {
                // Displays the front side of the flashcard
                FlashcardReadingView(
                    showFlashcardFront: $showStaticFlashcardFront,
                    flashcardDisplayModel: flashcardDisplayModel,
                    showHint: showHint,
                    showDifficultyLevel: showDifficultyLevel,
                    showDeckName: showDeckName,
                    frameWidth: max(0, frameWidth - (cardSpacing * 2)),
                    isFlippable: false,
                    aspectRatio: 1.2
                )
                // Displays the back side of the flashcard
                FlashcardReadingView(
                    showFlashcardFront: $showStaticFlashcardBack,
                    flashcardDisplayModel: flashcardDisplayModel,
                    showHint: showHint,
                    showDifficultyLevel: showDifficultyLevel,
                    showDeckName: showDeckName,
                    frameWidth: max(0, frameWidth - (cardSpacing * 2)),
                    isFlippable: false,
                    aspectRatio: 1.2
                )
            }
        }
    }
    
    /// A label indicating the end of the deck.
    private var endOfDeckLabel: some View {
        Text("End of Deck")
            .fontWeight(.semibold)
            .padding(.vertical, 10)
            .padding(.horizontal, 20)
            .foregroundStyle(.white)
            .background(Color.customSecondary)
            .clipDefaultShape()
    }
}

// MARK: - Preview
#if DEBUG
// Shows front only layout view
#Preview {
    ReadingListView(
        flashcardLayout: .constant(.frontOnly),
        flashcardDisplayModels: .constant(FlashcardDisplayModel.sampleArray),
        showHint: true,
        showDifficultyLevel: true,
        showDeckName: true
    )
}

// Shows front and back layout view
#Preview {
    ReadingListView(
        flashcardLayout: .constant(.frontAndBack),
        flashcardDisplayModels: .constant(FlashcardDisplayModel.sampleArray),
        showHint: false,
        showDifficultyLevel: false,
        showDeckName: false
    )
}
#endif
