//
//  CheckmarkCircleButton.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct CheckboxButton: View {
    @Binding var isChecked: Bool
    
    var body: some View {
        Button(action: {
            isChecked.toggle()
        }) {
            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .font(.customTitle3)
                .foregroundColor(DesignConstants.Colors.secondaryButtonForeground)
        }
    }
}

#if DEBUG
#Preview {
    CheckboxButton(
        isChecked: .constant(true)
    )
    CheckboxButton(
        isChecked: .constant(false)
    )
}
#endif
