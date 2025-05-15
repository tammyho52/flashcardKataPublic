//
//  GuestDefaultScreen.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Displays a default screen when the user enters as a guest (not logged in).

import SwiftUI

enum GuestViewType {
    case decks
    case read
    case kata
    case tracker
    case settings

    var description: String {
        switch self {
        case .decks:
            "Create custom decks & flashcards for your study journey."
        case .read:
            "Enjoy leisure flashcard reading in a relaxed environment."
        case .kata:
            "Choose from 4 interactive study modes for your review kata session. It's a lot of fun!"
        case .tracker:
            "Track your study progress here. Get started today & study your way."
        case .settings:
            "" // Will not show screen for settings
        }
    }
}

struct GuestDefaultScreen: View {
    let guestViewType: GuestViewType
    let buttonAction: () -> Void

    var body: some View {
        VStack(spacing: 35) {
            DefaultViewInlineImage(
                symbolName: "person.crop.circle.fill",
                foregroundColor: DesignConstants.Colors.iconSecondary
            )
            VStack(spacing: 10) {
                Text("Sign Up & Login to Get Started")
                    .font(.customHeadline)
                Text(guestViewType.description)
                    .foregroundStyle(Color.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)

            DefaultViewPrimaryButton(
                buttonAction: buttonAction,
                text: "Sign Up & Login"
            )
            .padding(.top, 50)
        }
        .background(.clear)
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        GuestDefaultScreen(guestViewType: .decks, buttonAction: {})
    }
}

#Preview {
    NavigationStack {
        GuestDefaultScreen(guestViewType: .kata, buttonAction: {})
    }
}

#Preview {
    NavigationStack {
        GuestDefaultScreen(guestViewType: .read, buttonAction: {})
    }
}

#Preview {
    NavigationStack {
        GuestDefaultScreen(guestViewType: .tracker, buttonAction: {})
    }
}
