//
//  FlashcardTagView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  A custom label that displays text with an optional SF Symbol icon.

import SwiftUI

struct FlashcardTagView: View {
    var text: String
    var symbolName: String?
    var foregroundColor: Color
    var backgroundColor: Color
    var useLightVariant: Bool = false

    var body: some View {
        Label {
            Text(text)
        } icon: {
            if let symbolName {
                Image(systemName: symbolName)
            }
        }
        .font(.customCallout)
        .fontWeight(.semibold)
        .fontWeight(.semibold)
        .padding(.vertical, 5)
        .padding(.horizontal, 10)
        .foregroundStyle(foregroundColor)
        .background(
            backgroundColor
                .saturation(useLightVariant ? 0.5 : 1)
        )
        .clipDefaultShape()
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    FlashcardTagView(text: "Flashcard", foregroundColor: .white, backgroundColor: .darkPurple)
}
#endif
