//
//  IconView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct IconView: View {
    let scoreType: ScoreType
    var font: Font = .title
    
    var body: some View {
        Image(systemName: scoreType.symbol)
            .font(font)
            .foregroundStyle(.white)
            .padding()
            .background(scoreType.backgroundColor)
            .clipDefaultShape()
            .shadow(radius: 2.5)
    }
}

#if DEBUG
#Preview {
    IconView(scoreType: .correct)
}
#endif
