//
//  ModifyDeckButton.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct ModifyActionButton: View {
    @Binding var showModifyButtons: Bool
    let action: () -> Void
    let symbolName: String
    
    var body: some View {
        Button {
            action()
            showModifyButtons = false
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

#if DEBUG
#Preview {
    ModifyActionButton(showModifyButtons: .constant(true), action: {}, symbolName: "pencil")
}
#endif
