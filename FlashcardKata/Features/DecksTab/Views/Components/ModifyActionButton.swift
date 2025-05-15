//
//  ModifyActionButton.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A reusable button component for triggering modify actions, such as editing or deleting, with a customizable icon.

import SwiftUI

/// A button for modifying actions, such as editing or deleting.
struct ModifyActionButton: View {
    // MARK: - Properties
    @Binding var showModifyButtons: Bool // Indicates whether the modify buttons are shown.
    let action: () -> Void
    let symbolName: String

    // MARK: - Body
    var body: some View {
        Button {
            action()
            showModifyButtons = false // Hide the buttons after action is performed.
        } label: {
            Image(systemName: symbolName)
                .font(.title3)
        }
        .padding(10)
        .foregroundStyle(.white)
        .frame(width: 40, height: 40)
        .background(.black.opacity(0.5))
        .clipShape(Circle())
        .buttonStyle(.plain)
        .contentShape(Circle())
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    ModifyActionButton(showModifyButtons: .constant(true), action: {}, symbolName: "pencil")
}
#endif
