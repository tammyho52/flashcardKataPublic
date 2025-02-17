//
//  AddDecksDisplay.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct AddDecksDisplay: View {
    @Binding var deck: Deck
    @Binding var newSubdeckName: SubdeckName
    @Binding var subdeckNames: [SubdeckName]
    
    let maximumSubDecks = 10
    
    var body: some View {
        VStack(spacing: 10) {
            deckNameTextField(deck: $deck)
            deckThemeMenu(deckTheme: $deck.theme)
            booksIconView
            AddSubdeckTextField(
                subdeckNames: $subdeckNames,
                subdeckName: $newSubdeckName,
                maximumSubDecks: maximumSubDecks
            )
        }
        .padding()
        .overlay {
            RoundedRectangle(cornerRadius: DesignConstants.Layout.cornerRadius)
                .stroke(deck.theme.primaryColor, lineWidth: 2.5)
        }
        .padding(.vertical, 10)
    }
    
    // MARK: - Components
    func deckNameTextField(deck: Binding<Deck>) -> some View {
        TextField("Deck Name", text: $deck.name)
            .applyInputControlStyle(backgroundColor: deck.wrappedValue.theme.primaryColor)
    }
    
    func deckThemeMenu(deckTheme: Binding<Theme>) -> some View {
        LabeledContent {
            Menu {
                ForEach(Theme.allCases, id: \.self) { theme in
                    Button(action: {
                        deckTheme.wrappedValue = theme
                    }) {
                        Text(theme.colorName)
                    }
                }
            } label: {
                Label {
                    Text("\(deckTheme.wrappedValue.colorName)")
                } icon: {
                    Image(systemName: "paintbrush.fill")
                }
                .foregroundStyle(deckTheme.wrappedValue.primaryColor)
            }
            .padding(.trailing, 10)
        } label: {
            Text("Deck Color")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .applyInputControlStyle(backgroundColor: deckTheme.wrappedValue.primaryColor)
    }
    
    var booksIconView: some View {
        Image(systemName: "books.vertical")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 50)
            .padding(.vertical, 5)
            .accessibility(hidden: true)
    }
}

private struct AddSubdeckTextField: View {
    @Binding var subdeckNames: [SubdeckName]
    @Binding var subdeckName: SubdeckName
    @FocusState private var subdeckNameIsFocused: Bool
    
    let maximumSubDecks: Int
    let maximumSubDeckText: String = "Maximum of 10 subdecks has been reached."
    var isDisabled: Bool {
        return subdeckName.name.isEmpty || isAtMaximumSubdecks
    }
    var isAtMaximumSubdecks: Bool {
        return subdeckNames.count == maximumSubDecks
    }
    
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                TextField("Add subdecks", text: $subdeckName.name)
                    .modifier(InputControlStyle(backgroundColor: .gray))
                    .focused($subdeckNameIsFocused)
                Button("Add") {
                    subdeckNames.append(subdeckName)
                    subdeckName = SubdeckName(name: "")
                    subdeckNameIsFocused = false
                }
                .padding(.vertical, 7.5)
                .padding(.horizontal, 10)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .background(isDisabled ? Color(.systemGray6) : .gray)
                .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Layout.cornerRadius))
                .disabled(isDisabled)
            }
            Text(maximumSubDeckText)
                .font(.customCaption)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.red)
                .opacity(isAtMaximumSubdecks ? 100 : 0)
                .padding(.leading, 5)
        }
    }
    
    private var isAtMaximumSubDecks: Bool {
        subdeckNames.count == maximumSubDecks
    }
}

#if DEBUG
#Preview {
    AddDecksDisplay(
        deck: .constant(Deck.sampleDeck),
        newSubdeckName: .constant(SubdeckName(name: "Software Engineering")),
        subdeckNames: .constant([])
    )
    .padding()
}

#Preview {
    AddDecksDisplay(
        deck: .constant(Deck()),
        newSubdeckName: .constant(SubdeckName()),
        subdeckNames: .constant([])
    )
    .padding()
}
#endif
