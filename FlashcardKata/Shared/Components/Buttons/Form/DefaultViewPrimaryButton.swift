//
//  DefaultViewPrimaryButton.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  View representing a primary button for the default view.

import SwiftUI

struct DefaultViewPrimaryButton: View {
    var buttonAction: () -> Void
    let text: String

    var body: some View {
        Button {
            buttonAction()
        } label: {
            HStack {
                Text(text)
                    .padding(.horizontal, 35)
                    .fontWeight(.bold)
                Image(systemName: "arrow.right")
                    .padding(10)
                    .foregroundStyle(Color.customSecondary)
                    .background(.white)
                    .clipShape(Circle())

            }
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.vertical, 5)
            .padding(.leading, 20)
            .padding(.trailing, 5)
            .background(Color.customSecondary)
            .clipShape(Capsule())
        }
    }
}

// MARK: - Preview
#Preview {
    DefaultViewPrimaryButton(buttonAction: {}, text: "Add Deck")
}
