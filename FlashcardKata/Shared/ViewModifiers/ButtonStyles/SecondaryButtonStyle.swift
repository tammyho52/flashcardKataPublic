//
//  SecondaryButtonStyle.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Button style used for secondary buttons.

import SwiftUI

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.customSubheadline)
            .fontWeight(.semibold)
            .padding(.horizontal)
            .padding(.vertical, 7.5)
            .foregroundStyle(DesignConstants.Colors.secondaryButtonForeground)
            .background(DesignConstants.Colors.secondaryButtonBackground)
            .clipShape(Capsule())
    }
}
