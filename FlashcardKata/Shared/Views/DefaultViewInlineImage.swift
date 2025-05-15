//
//  DefaultViewInlineImage.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//  View that renders a symbol as a large inline image.

import SwiftUI

struct DefaultViewInlineImage: View {
    let symbolName: String
    let foregroundColor: Color

    var body: some View {
        Image(systemName: symbolName)
            .symbolRenderingMode(.hierarchical)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .symbolVariant(.fill)
            .foregroundStyle(foregroundColor)
            .background(.clear)
            .frame(height: 100)
            .accessibility(hidden: true)
            .applyCoverShadow()
    }
}

// MARK: - Preview
#Preview {
    DefaultViewInlineImage(symbolName: "rectangle.on.rectangle", foregroundColor: Color.customSecondary)
}
