//
//  CustomHeaderTitleView.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Custom text view to display a section header title.

import SwiftUI

struct SectionHeaderTitle: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.customTitle3)
            .bold()
            .foregroundStyle(Color.customPrimary)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    SectionHeaderTitle(text: "Review Decks")
}
#endif
