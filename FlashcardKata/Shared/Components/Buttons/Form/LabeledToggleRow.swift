//
//  LabeledToggleRow.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  View representing a labeled list row with a toggle.

import SwiftUI

struct LabeledToggleRow: View {
    @Binding var isOn: Bool
    let labelText: String
    let symbol: String

    var body: some View {
        Toggle(isOn: $isOn) {
            Label {
                Text(labelText)
            } icon: {
                Image(systemName: symbol)
                    .foregroundStyle(DesignConstants.Colors.primaryButtonBackground)
            }
        }
        .tint(DesignConstants.Colors.primaryButtonBackground)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    LabeledToggleRow(isOn: .constant(true), labelText: "Show Hint", symbol: ContentConstants.Symbols.hint)
}
#endif
