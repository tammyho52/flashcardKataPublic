//
//  HeaderSelectionButton.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct HeaderSelectionButton: View {
    @Binding var isChecked: Bool
    var action: () -> Void
    let checkedSymbolName: String = "checkmark.circle.fill"
    let uncheckedSymbolName: String = "checkmark.circle"
    
    var body: some View {
        HeaderButton(
            isChecked: $isChecked,
            checkedSymbolName: checkedSymbolName,
            uncheckedSymbolName: uncheckedSymbolName
        ) {
            action()
        }
    }
}

#if DEBUG
#Preview {
    HeaderSelectionButton(isChecked: .constant(true), action: {})
}
#endif
