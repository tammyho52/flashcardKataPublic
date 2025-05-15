//
//  CompactLabel.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  A compact label displaying a SF Symbol and text.

import SwiftUI

struct CompactLabel: View {
    let text: String
    let symbol: String

    var body: some View {
        HStack {
            Image(systemName: symbol)
            Text(text)
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    CompactLabel(text: "300", symbol: "rectangle.on.rectangle")
}
#endif
