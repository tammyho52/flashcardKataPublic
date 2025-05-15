//
//  AddDecksDisplay.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view that provides an interface for creating and customizing decks and subdecks.

import SwiftUI

/// A view that displays input fields and controls for creating and managing decks and subdecks.
struct AddDecksDisplay: View {
    // MARK: - Properties
    @Binding var deck: Deck
    @Binding var newSubdeckName: SubdeckName
    @Binding var subdeckNames: [SubdeckName]

    // MARK: - Constants
    /// The maximum number of subdecks allowed for a single deck.
    let maximumSubdecks = 10

    // MARK: - Body
    var body: some View {
        VStack(spacing: 10) {
            deckNameTextField(deck: $deck)
                .accessibilityIdentifier("deckNameTextField")
            deckThemeMenu(deckTheme: $deck.theme)
            booksIconView // Decorative icon for the deck.
            AddSubdeckTextField(
                subdeckNames: $subdeckNames,
                subdeckName: $newSubdeckName,
                maximumSubdeckCount: maximumSubdecks
            )
        }
        .padding()
        .overlay {
            RoundedRectangle(cornerRadius: DesignConstants.Layout.cornerRadius)
                .stroke(deck.theme.primaryColor, lineWidth: 2.5)
        }
        .padding(.vertical, 10)
    }

    // MARK: - Helper Views
    /// Creates a text field for entering the deck name.
    /// - Parameter deck: A binding to the deck being modified.
    /// - Returns: A styled text field for the deck name.
    func deckNameTextField(deck: Binding<Deck>) -> some View {
        TextField("Deck Name", text: $deck.name)
            .applyTextFieldStyle(backgroundColor: deck.wrappedValue.theme.primaryColor)
            .autocorrectionDisabled()
    }
    
    /// Creates a menu for selecting the deck's theme.
    /// - Parameter deckTheme: A binding to the deck's theme.
    /// - Returns: A styled menu for theme selection.
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

    /// A decorative icon representing books, used in the view.
    private var booksIconView: some View {
        Image(systemName: "books.vertical")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 50)
            .padding(.vertical, 5)
            .accessibility(hidden: true)
    }
}

// MARK: - Add Subdeck Text Field
/// A view that provides a text field and button for adding subdecks to a deck.
private struct AddSubdeckTextField: View {
    @Binding var subdeckNames: [SubdeckName] // Data store for subdeck names.
    @Binding var subdeckName: SubdeckName // The name of the new subdeck being added.

    let maximumSubdeckCount: Int
    
    private var maximumSubdeckText: String { "Maximum of \(maximumSubdeckCount) subdecks has been reached."
    }
    private var isDisabled: Bool {
        return subdeckName.name.isEmpty || isAtMaximumSubdecks
    }
    private var isAtMaximumSubdecks: Bool {
        return subdeckNames.count == maximumSubdeckCount
    }
    private var isAtMaximumSubDecks: Bool {
        subdeckNames.count == maximumSubdeckCount
    }

    var body: some View {
        VStack(spacing: 5) {
            HStack {
                TextField("Add subdecks", text: $subdeckName.name)
                    .modifier(TextFieldStyle(backgroundColor: .gray))
                    .autocorrectionDisabled()
                
                Button("Add") {
                    subdeckNames.append(subdeckName)
                    subdeckName = SubdeckName(name: "")
                }
                .padding(.vertical, 7.5)
                .padding(.horizontal, 10)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .background(isDisabled ? Color(.systemGray6) : .gray)
                .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Layout.cornerRadius))
                .disabled(isDisabled)
            }
            
            // Display a message when the maximum number of subdecks is reached.
            Text(maximumSubdeckText)
                .font(.customCaption)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.red)
                .opacity(isAtMaximumSubdecks ? 100 : 0) // Controls visibility based on subdeck count.
                .padding(.leading, 5)
        }
    }
}

// MARK: - Preview
#if DEBUG
/// Less than maximum subdecks.
#Preview {
    AddDecksDisplay(
        deck: .constant(Deck.sampleDeck),
        newSubdeckName: .constant(SubdeckName(name: "Software Engineering")),
        subdeckNames: .constant([])
    )
    .padding()
}

/// Maximum subdecks reached.
#Preview {
    AddDecksDisplay(
        deck: .constant(Deck()),
        newSubdeckName: .constant(SubdeckName()),
        subdeckNames: .constant((0..<10).map { SubdeckName(name: "Subdeck \($0)") })
    )
    .padding()
}
#endif
