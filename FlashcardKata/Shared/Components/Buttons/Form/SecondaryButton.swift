//
//  FormActionButton.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  View representing a secondary button.

import SwiftUI

struct SecondaryButton: View {
    let text: String
    let symbol: String
    var contentStyle: SecondaryButtonContentStyle = .textAndSymbol
    let action: () async -> Void

    var body: some View {
        Button {
            Task {
                await action()
            }
        } label: {
            switch contentStyle {
            case .textOnly:
                Text(text)
            case .symbolOnly:
                Image(systemName: symbol)
            case .textAndSymbol:
                Label(text, systemImage: symbol)
            }
        }
        .buttonStyle(SecondaryButtonStyle())
    }
}

extension SecondaryButton {
    init(text: String, action: @escaping () async -> Void) {
        self.contentStyle = .textOnly
        self.text = text
        self.symbol = ""
        self.action = action
    }

    init(symbol: String, action: @escaping () async -> Void) {
        self.contentStyle = .symbolOnly
        self.text = ""
        self.symbol = symbol
        self.action = action
    }
}

enum SecondaryButtonContentStyle {
    case textOnly
    case symbolOnly
    case textAndSymbol
}

// MARK: - Preview
#if DEBUG
#Preview {
    SecondaryButton(text: "Create Account", symbol: "person.fill", action: {})
    SecondaryButton(symbol: "person.fill", action: {})
    SecondaryButton(text: "Create Account", action: {})
}
#endif
