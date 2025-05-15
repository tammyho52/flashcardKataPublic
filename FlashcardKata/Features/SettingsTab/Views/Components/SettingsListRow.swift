//
//  SettingsListRow.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  This custom row view is designed for the Settings List, displaying an icon and title.

import SwiftUI

/// A custom row view for the Settings List, displaying an icon and title.
struct SettingsListRow: View {
    // MARK: - Properties
    @ScaledMetric var symbolSideLength = 30
    let action: () async throws -> Void
    let title: String
    let symbol: String
    var role: ButtonRole?

    // MARK: - Body
    var body: some View {
        Button(role: role, action: {
            Task { try await action() }
        }, label: {
            HStack {
                // Overlay to ensure the icon is centered with consistent spacing
                Color.clear
                    .frame(maxWidth: symbolSideLength, maxHeight: symbolSideLength)
                    .overlay {
                        Image(systemName: symbol)
                            .resizable()
                            .scaledToFit()
                            .padding(.trailing, 10)
                            .font(.title3)
                            .foregroundStyle(Color.customAccent)
                    }
                Text(title)
                    .fontWeight(.semibold)
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 6.5)
            .contentShape(RoundedRectangle(cornerRadius: DesignConstants.Layout.cornerRadius))
        })
        .listRowBackground(Color.white.opacity(0.8))
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    List {
        SettingsListRow(action: {}, title: "Rate Us", symbol: ContentConstants.Symbols.privatePolicy)
    }
    .listStyle(.insetGrouped)
    .padding(.horizontal)
    .background(.clear)
    .scrollContentBackground(.hidden)
}
#endif
