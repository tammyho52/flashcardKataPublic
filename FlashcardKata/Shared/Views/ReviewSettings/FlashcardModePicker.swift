//
//  FlashcardPicker.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Component that allows the user to pick flashcard selection mode for review.

import SwiftUI

struct FlashcardModePicker: View {
    @Binding var selectedFlashcardMode: FlashcardMode
    @Binding var showCustomSelectionView: Bool

    let clearSelectedFlashcardIDs: () -> Void

    var body: some View {
        HStack {
            Button {
                selectedFlashcardMode = .shuffle
                clearSelectedFlashcardIDs()
            } label: {
                ReviewModeTile(symbolName: ContentConstants.Symbols.shuffle, description: "Shuffle")
            }
            .buttonStyle(.plain)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(selectedFlashcardMode == .shuffle ? Color.customAccent : Color.clear, lineWidth: 3)
            )
            .opacity(selectedFlashcardMode == .shuffle ? 1 : 0.5)

            Button {
                selectedFlashcardMode = .custom
                showCustomSelectionView = true
            } label: {
                ReviewModeTile(symbolName: ContentConstants.Symbols.customFlashcardMode, description: "Custom")
            }
            .accessibilityIdentifier("customCardSelectionButton")
            .buttonStyle(.plain)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(selectedFlashcardMode == .custom ? Color.customAccent : Color.clear, lineWidth: 3)
            )
            .opacity(selectedFlashcardMode == .custom ? 1 : 0.5)
        }
    }
}

private struct FlashcardModeButton: View {
    var action: () -> Void
    var labelText: String
    var SFSymbol: String
    var isSelected: Bool

    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: SFSymbol)
                Text(labelText)
            }
        }
        .listRowSeparator(.hidden)
        .fontWeight(.semibold)
        .padding(.vertical, 7.5)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .aspectRatio(1.5, contentMode: .fit)
        .foregroundStyle(Color.customPrimary)
        .background(isSelected ? Color.customAccent3 : .white)
        .clipDefaultShape()
        .overlay {
            RoundedRectangle(cornerRadius: DesignConstants.Layout.cornerRadius)
                .strokeBorder(Color.customSecondary, lineWidth: 2)
        }
        .applyCoverShadow()
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    FlashcardModePicker(
        selectedFlashcardMode: .constant(.shuffle),
        showCustomSelectionView: .constant(false),
        clearSelectedFlashcardIDs: {}
    )
}
#endif
