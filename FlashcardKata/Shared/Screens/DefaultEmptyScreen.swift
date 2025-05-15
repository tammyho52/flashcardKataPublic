//
//  DefaultEmptyDeckView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Displays a default screen when the user has no decks or no flashcard available.

import SwiftUI

struct DefaultEmptyScreen: View {
    let defaultEmptyViewType: DefaultEmptyViewType
    var buttonAction: () -> Void
    var showButton: Bool = true

    var body: some View {
        VStack(spacing: 35) {
            DefaultViewInlineImage(
                symbolName: defaultEmptyViewType.iconSymbolName,
                foregroundColor: DesignConstants.Colors.iconSecondary
            )
            VStack(spacing: 10) {
                Text("No \(defaultEmptyViewType.description)")
                    .font(.customHeadline)
                    .multilineTextAlignment(.center)
                Text(defaultEmptyViewType.instructionsText)
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
            }
            if showButton {
                DefaultViewPrimaryButton(
                    buttonAction: buttonAction,
                    text: defaultEmptyViewType.buttonText
                )
                .padding(.top, 50)
            }
        }
        .background(.clear)
        .accessibilityElement(children: .combine)
        .accessibilityIdentifier("flashcardListScreenEmpty")
    }
}

extension DefaultEmptyScreen {
    enum DefaultEmptyViewType {
        case deck
        case flashcard
        case getStarted

        var buttonText: String {
            switch self {
            case .deck:
                "Add Deck"
            case .flashcard:
                "Add Flashcard"
            case .getStarted:
                "Get Started"
            }
        }

        var description: String {
            switch self {
            case .deck:
                "Decks"
            case .flashcard:
                "Flashcards"
            case .getStarted:
                "Documents"
            }
        }

        var instructionsText: String {
            switch self {
            case .deck:
                return "Create a deck to get started"
            case .flashcard:
                return "Create a flashcard to get started"
            case .getStarted:
                return "Create a flashcard deck to get started"
            }
        }

        var inlineSymbolName: String {
            switch self {
            case .deck:
                "rectangle.stack.badge.plus"
            case .flashcard:
                "rectangle.badge.plus"
            case .getStarted:
                "play.rectangle.fill"
            }
        }

        var iconSymbolName: String {
            switch self {
            case .deck:
                ContentConstants.Symbols.deck
            case .flashcard:
                ContentConstants.Symbols.flashcard
            case .getStarted:
                "play.rectangle.on.rectangle.circle.fill"
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    NavigationStack {
        DefaultEmptyScreen(defaultEmptyViewType: .deck, buttonAction: {})
    }
}

#Preview {
    DefaultEmptyScreen(defaultEmptyViewType: .flashcard, buttonAction: {})
}

#Preview {
    DefaultEmptyScreen(defaultEmptyViewType: .getStarted, buttonAction: {})
}
#endif
