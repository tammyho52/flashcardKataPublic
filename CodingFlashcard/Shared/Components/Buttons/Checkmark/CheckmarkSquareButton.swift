//
//  CheckmarkButton.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct CheckmarkSquareButton: View {
    var isChecked: Bool
    var foregroundColor: Color
    
    var body: some View {
        Image(systemName: isChecked ? "checkmark.circle.fill" : "checkmark.circle")
            .font(.customTitle2)
            .foregroundColor(foregroundColor)
    }
}

#if DEBUG
#Preview {
    CheckmarkSquareButton(isChecked: true, foregroundColor: .black)
}
#endif

