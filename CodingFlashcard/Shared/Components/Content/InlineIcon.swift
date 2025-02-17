//
//  LargeIcon.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct InlineIcon: View {
    let symbol: String
    
    var body: some View {
        Image(systemName: symbol)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 20, height: 20)
            .foregroundStyle(Color.customPrimary)
            .font(.customTitle3)
    }
}

#if DEBUG
#Preview {
    InlineIcon(symbol: "person.fill")
}
#endif
