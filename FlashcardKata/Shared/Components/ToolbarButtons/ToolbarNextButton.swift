//
//  ToolbarNextButton.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  A toolbar button for navigating forward in a navigation stack.

import SwiftUI

@ToolbarContentBuilder
func toolbarNextButton(isDisabled: Bool? = nil, action: @escaping () -> Void) -> some ToolbarContent {
    toolbarIconButton(
        isDisabled: isDisabled,
        action: action,
        icon: "chevron.right",
        placement: .topBarTrailing,
        accessibilityIdentifier: "toolbarNextButton"
    )
}

// MARK: - Preview
#if DEBUG
#Preview {
    struct TestView: View {
        let action: () -> Void = {
            print("Test")
        }

        var body: some View {
            NavigationStack {
                Text("Hello World")
                    .toolbar {
                        toolbarNextButton(action: action)
                    }
            }
        }
    }
    return TestView()
}
#endif
