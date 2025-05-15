//
//  ToolbarBackButton.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  A toolbar button for navigating back in a navigation stack.

import SwiftUI

@ToolbarContentBuilder
func toolbarBackButton(isDisabled: Bool? = nil, action: @escaping () -> Void) -> some ToolbarContent {
    toolbarIconButton(isDisabled: isDisabled, action: action, icon: "chevron.left", placement: .topBarLeading)
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
                        toolbarBackButton(action: action)
                    }
            }
        }
    }
    return TestView()
}
#endif
