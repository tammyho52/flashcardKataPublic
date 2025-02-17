//
//  PrimaryButtonStyle.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    var isDisabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .padding()
            .padding(.horizontal, 20)
            .foregroundStyle(DesignConstants.Colors.primaryButtonForeground)
            .background(isDisabled ? DesignConstants.Colors.buttonDisabled : DesignConstants.Colors.primaryButtonBackground)
            .disabled(isDisabled)
            .clipShape(Capsule())
    }
}
