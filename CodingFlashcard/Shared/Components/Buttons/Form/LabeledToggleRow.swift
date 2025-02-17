//
//  LabeledToggleRow.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct LabeledToggleRow: View {
    @Binding var isOn: Bool
    let labelText: String
    let symbol: String
    
    var body: some View {
        Toggle(isOn: $isOn) {
            Label {
                Text(labelText)
            } icon: {
                Image(systemName: symbol)
                    .foregroundStyle(DesignConstants.Colors.primaryButtonBackground)
            }
        }
        .tint(DesignConstants.Colors.primaryButtonBackground)
    }
}

#if DEBUG
#Preview {
    LabeledToggleRow(isOn: .constant(true), labelText: "Show Hint", symbol: ContentConstants.Symbols.hint)
}
#endif
