//
//  HeaderSelectionButton.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct HeaderButton: View {
    @Binding var isChecked: Bool
    var checkedSymbolName: String
    var uncheckedSymbolName: String
    var action: () -> Void
    
    var body: some View {
        Button {
            withAnimation {
                action()
            }
        } label: {
            Image(systemName: isChecked ? checkedSymbolName : uncheckedSymbolName)
                .font(.title3)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
        .background(Color.customSecondary)
        .foregroundStyle(.white)
        .fontWeight(.semibold)
        .clipDefaultShape()
        .applyCoverShadow()
    }
}

#if DEBUG
#Preview {
    HeaderButton(isChecked: .constant(true), checkedSymbolName: "checkmark.circle.fill", uncheckedSymbolName: "checkmark.circle", action: {})
}
#endif
