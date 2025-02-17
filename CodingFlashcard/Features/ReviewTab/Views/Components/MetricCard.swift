//
//  ReviewBox.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct MetricCard: View {
    let number: Int
    let metric: String
    let imageName: String
    let imageColor: Color
    let backgroundColor: Color
    
    var body: some View {
        VStack {
            Text("\(number)")
                .font(.customTitle3)
                .foregroundStyle(DesignConstants.Colors.primaryText)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, 20)
            Text(metric)
                .font(.customHeadline)
                .foregroundStyle(DesignConstants.Colors.secondaryText)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .overlay(alignment: .topTrailing) {
            Image(systemName: imageName)
                .font(.title)
                .foregroundStyle(imageColor)
                .font(.title)
                .fontWeight(.semibold)
                .padding(.trailing, 5)
        }
        .padding()
        .background(backgroundColor)
        .clipDefaultShape()
    }
}

#if DEBUG
#Preview {
    MetricCard(number: 30, metric: "Minutes", imageName: "timer", imageColor: Color.customSecondary, backgroundColor: .white.opacity(0.8))
}
#endif
