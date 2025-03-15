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
            .frame(height: 100)
            .accessibility(hidden: true)
            .applyCoverShadow()
    }
}

#Preview {
    DefaultViewInlineImage(symbolName: "rectangle.on.rectangle", foregroundColor: Color.customSecondary)
}
