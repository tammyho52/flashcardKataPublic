//
//  ToolbarExitButton.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

@ToolbarContentBuilder
func toolbarExitButton(isDisabled: Bool? = nil, action: @escaping () -> Void) -> some ToolbarContent {
    ToolbarItem(placement: .topBarLeading) {
        Button(action: action) {
            Image(systemName: "x.circle.fill")
                .fontWeight(.semibold)
                .font(.title3)
        }
        .tint(Color.customSecondary)
        .disabled(isDisabled ?? false)
    }
}

#if DEBUG
#Preview {
    struct TestView: View {
        let action: () -> Void = {
            print("Hello")
        }
        
        var body: some View {
            NavigationStack {
                Text("Hello World")
                    .toolbar {
                        toolbarExitButton(action: action)
                    }
            }
        }
    }
    return TestView()
}
#endif
