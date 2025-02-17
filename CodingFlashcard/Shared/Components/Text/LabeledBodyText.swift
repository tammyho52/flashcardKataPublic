//
//  FlashcardTextView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct LabeledBodyText: View {
    var flashcardTextType: FlashcardTextType
    
    var body: some View {
        Group {
            if let header = flashcardTextType.header {
                Text("\(header): ")
                    .foregroundStyle(Color.customSecondary)
                    .fontWeight(.bold)
                + Text(flashcardTextType.body)
            } else {
                Text(flashcardTextType.body)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}

enum FlashcardTextType {
    case frontText(String)
    case backText(String)
    case notes(String)
    case hint(String)
    
    var header: String? {
        switch self {
        case .frontText:
            return nil
        case .backText:
            return nil
        case .notes:
            return "Notes"
        case .hint:
            return "Hint"
        }
    }
    
    var body: String {
        switch self {
        case .frontText(let text), .backText(let text), .notes(let text), .hint(let text):
            return text
        }
    }
}

#if DEBUG
#Preview {
    LabeledBodyText(flashcardTextType: .frontText("Front Text Example"))
    LabeledBodyText(flashcardTextType: .backText("Back Text Example"))
    LabeledBodyText(flashcardTextType: .hint("Hint Example"))
    LabeledBodyText(flashcardTextType: .notes("Notes Example"))
}
#endif
