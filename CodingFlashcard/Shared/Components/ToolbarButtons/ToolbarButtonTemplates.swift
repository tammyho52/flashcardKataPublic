//
//  ToolbarButtons.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

@ToolbarContentBuilder
func toolbarIconButton(isDisabled: Bool? = nil, action: @escaping () -> Void, icon: String, placement: ToolbarItemPlacement) -> some ToolbarContent {
    ToolbarItem(placement: placement) {
        Button(action: action) {
            Image(systemName: icon)
                .fontWeight(.semibold)
        }
        .tint(Color.customSecondary)
        .disabled(isDisabled ?? false)
    }
}

@ToolbarContentBuilder
func toolbarTextButton(isDisabled: Bool? = nil, action: @escaping () -> Void, text: String, placement: ToolbarItemPlacement) -> some ToolbarContent {
    ToolbarItem(placement: placement) {
        Button(action: action) {
            Text(text)
                .fontWeight(.semibold)
        }
        .tint(Color.customSecondary)
        .disabled(isDisabled ?? false)
    }
}

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
