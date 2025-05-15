//
//  HeaderExpansionButton.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  View representing a button for expand all and collapse all.

import SwiftUI

struct HeaderExpansionButton: View {
    @Binding var isChecked: Bool
    var action: () -> Void
    let checkedSymbolName: String = "chevron.down.circle.fill"
    let uncheckedSymbolName: String = "chevron.right.circle"

    var body: some View {
        HeaderButton(
            isChecked: $isChecked,
            checkedSymbolName: checkedSymbolName,
            uncheckedSymbolName: uncheckedSymbolName
        ) {
            action()
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    HeaderExpansionButton(isChecked: .constant(true), action: {})
}
#endif
