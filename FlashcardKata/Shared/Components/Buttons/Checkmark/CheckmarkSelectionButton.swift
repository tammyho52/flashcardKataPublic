//
//  CheckmarkSelectionButton.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  View representing a checkmark button for selection.

import SwiftUI

struct CheckmarkSelectionButton: View {
    @Binding var isChecked: Bool
    var text: String
    var fontWeight: Font.Weight
    var buttonAction: () -> Void

    var body: some View {
        Button {
            buttonAction()
        } label: {
            HStack(alignment: .top, spacing: 10) {
                Button {
                    buttonAction()
                } label: {
                    Image(systemName: "checkmark.circle")
                        .font(.title3)
                        .foregroundStyle(Color.customSecondary)
                        .symbolVariant(isChecked ? .fill : .none)
                }

                Text(text)
                    .fontWeight(fontWeight)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3, reservesSpace: false)
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    CheckmarkSelectionButton(
        isChecked: .constant(true),
        text: "Software Engineering",
        fontWeight: .semibold, buttonAction: {}
    )
}
#endif
