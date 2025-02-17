//
//  TappableLink.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct TappableLink: View {
    let text: String
    let action: () -> Void

    var body: some View {
        Text(text)
            .fontWeight(.semibold)
            .foregroundStyle(Colors.primaryText)
            .underline(color: Colors.textBackground)
            .onTapGesture(perform: action)
    }
}

#if DEBUG
#Preview {
    TappableLink(text: "Link", action: {})
}
#endif
