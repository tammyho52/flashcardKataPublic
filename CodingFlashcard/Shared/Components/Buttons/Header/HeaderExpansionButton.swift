//
//  HeaderExpansionButton.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct HeaderExpansionButton: View {
    @Binding var isChecked: Bool
    var action: () -> Void
    let checkedSymbolName: String = "chevron.down.circle.fill"
    let uncheckedSymbolName: String = "chevron.right.circle"
    
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
    HeaderExpansionButton(isChecked: .constant(true), action: {})
}
#endif
