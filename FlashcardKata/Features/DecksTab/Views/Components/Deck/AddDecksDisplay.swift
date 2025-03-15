//
//  AddDecksDisplay.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View that displays deck and subdeck creation fields.

import SwiftUI

struct AddDecksDisplay: View {
    @Binding var deck: Deck
    @Binding var newSubdeckName: SubdeckName
    @Binding var subdeckNames: [SubdeckName]

    let maximumSubDecks = 10 // Sets limit to number of subdecks.

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
            .applyTextFieldStyle(backgroundColor: deck.wrappedValue.theme.primaryColor)
    }

    func deckThemeMenu(deckTheme: Binding<Theme>) -> some View {
        LabeledContent {
            Menu {
                ForEach(Theme.allCases, id: \.self) { theme in
                    Button {
                        deckTheme.wrappedValue = theme
                    } label: {
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
        .applyTextFieldStyle(backgroundColor: deckTheme.wrappedValue.primaryColor)
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
                    .modifier(TextFieldStyle(backgroundColor: .gray))
                    .focused($subdeckNameIsFocused)
                Button("Add") {
                    // Adds subdeck, clears the subdeck name field, and removes keyboard focused field.
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
