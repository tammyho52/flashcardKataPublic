//
//  GeneralScoreView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct GeneralScoreView: View {
    @Binding var score: Int
    let scoreType: ScoreType
    
    var body: some View {
        HStack {
            Image(systemName: scoreType.symbol)
                .foregroundStyle(scoreType.backgroundColor)
                .font(.title2)
                .padding(.trailing, 5)
            Text("\(score)")
                .font(.customHeadline)
                .fontWeight(.bold)
        }
        .frame(width: 75)
        .fontWeight(.semibold)
        .padding()
        .background(.white.opacity(0.8))
        .background(.white)
        .clipShape(Capsule())
    }
}

#if DEBUG
#Preview {
    GeneralScoreView(score: .constant(1), scoreType: .correct)
}
#endif
