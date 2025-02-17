//
//  ToolbarNextButton.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

@ToolbarContentBuilder
func toolbarNextButton(isDisabled: Bool? = nil, action: @escaping () -> Void) -> some ToolbarContent {
    toolbarIconButton(isDisabled: isDisabled, action: action, icon: "chevron.right", placement: .topBarTrailing)
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
                        toolbarNextButton(action: action)
                    }
            }
        }
    }
    return TestView()
}
#endif
