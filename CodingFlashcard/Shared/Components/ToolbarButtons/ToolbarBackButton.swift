//
//  ToolbarBackButton.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

@ToolbarContentBuilder
func toolbarBackButton(isDisabled: Bool? = nil, action: @escaping () -> Void) -> some ToolbarContent {
    toolbarIconButton(isDisabled: isDisabled, action: action, icon: "chevron.left", placement: .topBarLeading)
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
                        toolbarBackButton(action: action)
                    }
            }
        }
    }
    return TestView()
}
#endif
