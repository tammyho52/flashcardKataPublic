//
//  CustomHeaderTitleView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

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

#if DEBUG
#Preview {
    SectionHeaderTitle(text: "Review Decks")
}
#endif
