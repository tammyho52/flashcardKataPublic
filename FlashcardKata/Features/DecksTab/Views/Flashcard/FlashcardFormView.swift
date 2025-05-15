//
//  FlashcardFormView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View that provides a form for creating or modifying flashcards, including optional fields and delete functionality.

import SwiftUI

/// A view that displays a form for creating or modifying a flashcard.
struct FlashcardFormView: View {
    // MARK: - Properties
    @State private var optionalSectionExpanded: Bool = true
    @Binding var flashcard: Flashcard

    var showDeleteFlashcardButton: Bool
    var deleteFlashcardAction: () -> Void

    // MARK: - Body
    var body: some View {
        List {
            // Section for selecting the difficulty level of the flashcard.
            Section {
                difficultyLevelPicker
            } header: {
                Text("Difficulty Level")
                    .applyListSectionStyle()
            }
            .listSectionSeparator(.hidden)

            // Section for entering the front text of the flashcard.
            Section {
                FlashcardBodyTextField(
                    flashcardText: $flashcard.frontText,
                    textFieldLabel: "Questions, text, etc."
                )
                .accessibilityIdentifier("flashcardFrontTextField")
            } header: {
                Text("Front Side")
                    .applyListSectionStyle()
            }
            .listSectionSeparator(.hidden)
            
            // Section for entering the back text of the flashcard.
            Section {
                FlashcardBodyTextField(
                    flashcardText: $flashcard.backText,
                    textFieldLabel: "Answers, text, etc."
                )
            } header: {
                Text("Back Side")
                    .applyListSectionStyle()
            }
            .listSectionSeparator(.hidden)
            
            // Section for optional fields such as hints and notes.
            Section {
                DisclosureGroup("Optional Fields", isExpanded: $optionalSectionExpanded) {
                    OptionalTextFieldView(
                        textFieldText: $flashcard.hint,
                        SFSymbol: "lightbulb.min",
                        textFieldLabel: "Hints"
                    )
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))

                    OptionalTextFieldView(
                        textFieldText: $flashcard.notes,
                        SFSymbol: "note.text",
                        textFieldLabel: "Notes"
                    )
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
                }
            }
            .listRowSeparator(.hidden)
            .listSectionSeparator(.hidden)

            // Delete button for removing the flashcard, used for edit flashcard views.
            if showDeleteFlashcardButton {
                Button("Delete Flashcard", role: .destructive) {
                    deleteFlashcardAction()
                }
                .padding(.top, 50)
                .frame(maxWidth: .infinity, alignment: .center)
                .listRowSeparator(.hidden)
                .listSectionSeparator(.hidden)
            }
        }
        .listStyle(.inset)
        .scrollDismissesKeyboard(.immediately)
        .accessibilityElement(children: .contain)
    }

    // MARK: - Helper Views
    /// A segmented picker for selecting the difficulty level of the flashcard.
    var difficultyLevelPicker: some View {
        Picker("Difficulty Level", selection: $flashcard.difficultyLevel) {
            ForEach(DifficultyLevel.allCases, id: \.self) { difficultyLevel in
                Text(difficultyLevel.description)
                    .tag(difficultyLevel)
            }
        }
        .pickerStyle(.segmented)
    }
}

// MARK: - Private Views
/// A reusable text field for entering the front and back text of the flashcard.
private struct FlashcardBodyTextField: View {
    @Binding var flashcardText: String
    let textFieldLabel: String

    var body: some View {
        TextField(textFieldLabel, text: $flashcardText, axis: .vertical)
            .lineLimit(3, reservesSpace: true)
            .padding(10)
            .autocorrectionDisabled() // Disables autocorrection to avoid known CoreGraphics issues.
            .overlay {
                RoundedRectangle(cornerRadius: DesignConstants.Layout.cornerRadius)
                    .stroke(.black, lineWidth: 1)
                    .shadow(color: .gray, radius: 0.5)
            }
    }
}

/// A reusable text field for entering optional fields such as hints and notes.
private struct OptionalTextFieldView: View {
    @Binding var textFieldText: String // The text entered in the field.
    let SFSymbol: String // The SF Symbol displayed next to the text field.
    let textFieldLabel: String // The label displayed in the text field.

    var body: some View {
        HStack {
            Image(systemName: SFSymbol)
                .padding(.horizontal, 5)
            TextField(textFieldLabel, text: $textFieldText, axis: .vertical)
                .lineLimit(3)
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .background(Color(.systemGray6))
                .clipDefaultShape()
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    NavigationStack {
        FlashcardFormView(
            flashcard: .constant(Flashcard.sampleFlashcard),
            showDeleteFlashcardButton: true,
            deleteFlashcardAction: {}
        )
    }
}
#endif
