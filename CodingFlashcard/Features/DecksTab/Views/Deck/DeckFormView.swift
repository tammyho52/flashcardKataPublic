//
//  DeckFormView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct DeckFormView: View {
    @State var subdeckName: SubdeckName = SubdeckName()
    @Binding var deck: Deck
    @Binding var subdeckNames: [SubdeckName]
    @Binding var isSaveButtonDisabled: Bool
    var saveButtonTitle: String
    var saveButtonAction: () -> Void
    let isEditView: Bool
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 10) {
                AddDecksDisplay(
                    deck: $deck,
                    newSubdeckName: $subdeckName,
                    subdeckNames: $subdeckNames
                )
                
                AddSubDecksDisplay(
                    subdecksNames: $subdeckNames,
                    isEditView: isEditView
                )
                .padding(.bottom, 20)
                
                DeckFormButton(
                    isDisabled: $isSaveButtonDisabled,
                    title: saveButtonTitle,
                    action: saveButtonAction
                )
            }
            .padding(.horizontal)
        }
    }
}

extension DeckFormView {
    private struct DeckFormButton: View {
        @Binding var isDisabled: Bool
        var title: String
        var action: () -> Void
        
        var body: some View {
            Button(title) {
                action()
            }
            .padding(.vertical, 7.5)
            .padding(.horizontal, 25)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .background(isDisabled ? Color(.systemGray6) : Color.customSecondary)
            .clipShape(Capsule())
            .disabled(isDisabled)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        DeckFormView(subdeckName: SubdeckName.sampleSubdeckName, deck: .constant(Deck()), subdeckNames: .constant([]), isSaveButtonDisabled: .constant(false), saveButtonTitle: "Create Deck", saveButtonAction: {}, isEditView: true)
    }
}
#endif
