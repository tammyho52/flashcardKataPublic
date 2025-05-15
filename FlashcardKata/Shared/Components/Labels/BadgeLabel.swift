//
//  BadgeLabel.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  A styled label displaying text with a customizable background.

import SwiftUI

struct BadgeLabel: View {
    var text: String
    var backgroundColor: Color

    var lineLimit = 1
    var foregroundColor: Color = Colors.primaryText
    var useMaxWidth: Bool = false

    var body: some View {
        Text(text)
            .lineLimit(lineLimit)
            .font(.customCallout)
            .fontWeight(.semibold)
            .padding(.vertical, 7.5)
            .padding(.horizontal, 10)
            .applyInfiniteWidth(if: useMaxWidth)
            .foregroundStyle(foregroundColor)
            .background(backgroundColor)
            .clipDefaultShape()
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    BadgeLabel(text: "Medium", backgroundColor: .yellow)
}

#Preview {
    BadgeLabel(text: "Medium", backgroundColor: .yellow, useMaxWidth: true)
}
#endif
