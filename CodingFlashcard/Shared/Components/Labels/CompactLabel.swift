//
//  CompactLabel.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

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

#if DEBUG
#Preview {
    CompactLabel(text: "300", symbol: "rectangle.on.rectangle")
}
#endif
