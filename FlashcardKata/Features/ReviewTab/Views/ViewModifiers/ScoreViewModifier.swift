//
//  ScoreViewModifier.swift
//  CodingFlashcard
//
//  Created by Tammy Ho on 7/17/24.
//

import SwiftUI

struct ScoreViewModifier: ViewModifier {
    let color: Color
    func body(content: Content) -> some View {
        content
            .fontWeight(.semibold)
            .foregroundStyle(color)
            .padding(.vertical, 5)
            .padding(.horizontal, 20)
            .frame(minWidth: 50)
            .background(Color(.systemGray6))
            .clipDefaultShape()
            .padding(.horizontal, 10)
    }
}

#Preview {
    Text("Score")
        .modifier(ScoreViewModifier(color: .blue))
}
