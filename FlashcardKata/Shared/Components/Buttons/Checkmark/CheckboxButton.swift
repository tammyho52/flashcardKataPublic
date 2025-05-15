//
//  CheckmarkCircleButton.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  View representing a checkmark button for agreement.

import SwiftUI

struct CheckboxButton: View {
    @Binding var isChecked: Bool

    var body: some View {
        Button {
            isChecked.toggle()
        } label: {
            Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                .font(.customTitle3)
                .foregroundColor(DesignConstants.Colors.secondaryButtonForeground)
        }
    }
}

// MARK: - Preview
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
