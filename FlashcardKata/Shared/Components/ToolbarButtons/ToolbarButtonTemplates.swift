//
//  ToolbarButtons.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Toolbar buttons with either an icon or text for use in a navigation toolbar.

import SwiftUI

@ToolbarContentBuilder
func toolbarIconButton(
    isDisabled: Bool? = nil,
    action: @escaping () -> Void,
    icon: String,
    placement: ToolbarItemPlacement,
    accessibilityIdentifier: String? = nil
) -> some ToolbarContent {
    ToolbarItem(placement: placement) {
        Button(action: action) {
            Image(systemName: icon)
                .fontWeight(.semibold)
        }
        .disabled(isDisabled ?? false)
        .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }
}

@ToolbarContentBuilder
func toolbarTextButton(
    isDisabled: Bool? = nil,
    action: @escaping () -> Void,
    text: String,
    placement: ToolbarItemPlacement,
    accessibilityIdentifier: String? = nil
) -> some ToolbarContent {
    ToolbarItem(placement: placement) {
        Button(action: action) {
            Text(text)
                .fontWeight(.semibold)
        }
        .disabled(isDisabled ?? false)
        .accessibilityIdentifier(accessibilityIdentifier ?? "")
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    NavigationStack {
        Text("Hello World")
            .toolbar {
                toolbarIconButton(action: {}, icon: "chevron.left", placement: .topBarLeading)
                toolbarTextButton(action: {}, text: "Next", placement: .topBarTrailing)
            }
    }
}
#endif
