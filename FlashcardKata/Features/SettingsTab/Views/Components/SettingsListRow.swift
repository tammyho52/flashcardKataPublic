//
//  CapsuleRow.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  Custom row view for Settings List, displaying an icon and title.

import SwiftUI

struct SettingsListRow: View {
    @ScaledMetric var symbolSideLength = 30
    let action: () async throws -> Void
    let title: String
    let symbol: String
    var role: ButtonRole?

    var body: some View {

        Button(role: role, action: {
            Task { try await action() }
        }, label: {
            HStack {
                // Ensures consistent symbol sizing using overlay
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

#if DEBUG
#Preview {
    List {
        SettingsListRow(action: {}, title: "Rate Us", symbol: ContentConstants.Symbols.privatePolicy)
        SettingsListRow(action: {}, title: "Rate Us", symbol: ContentConstants.Symbols.rateUs)
        SettingsListRow(action: {}, title: "Rate Us", symbol: ContentConstants.Symbols.signOut)
        SettingsListRow(action: {}, title: "Rate Us", symbol: ContentConstants.Symbols.deleteAccount)
    }
    .listStyle(.insetGrouped)
    .padding(.horizontal)
    .background(.clear)
    .scrollContentBackground(.hidden)
}
#endif
