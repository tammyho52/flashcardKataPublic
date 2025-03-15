//
//  ModifyFlashcardFields.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View that displays flashcard form fields.

import SwiftUI

struct FlashcardFormView: View {
    @State private var optionalSectionExpanded: Bool = true
    @Binding var flashcard: Flashcard
    @Binding var focusedField: FlashcardFormField?
    @FocusState var internalField: FlashcardFormField?

    var showDeleteFlashcardButton: Bool = true
    var deleteFlashcardAction: () -> Void = { }

    var body: some View {
        List {
            Section {
                difficultyLevelPicker
            } header: {
                Text("Difficulty Level")
                    .applyListSectionStyle()
            }
            .listSectionSeparator(.hidden)

            Section {
                FlashcardBodyTextField(
                    flashcardText: $flashcard.frontText,
                    textFieldLabel: "Questions, text, etc."
                )
                .focused($internalField, equals: .frontText)
            } header: {
                Text("Front Side")
                    .applyListSectionStyle()
            }
            .listSectionSeparator(.hidden)

            Section {
                FlashcardBodyTextField(
                    flashcardText: $flashcard.backText,
                    textFieldLabel: "Answers, text, etc."
                )
                .focused($internalField, equals: .backText)
            } header: {
                Text("Back Side")
                    .applyListSectionStyle()
            }
            .listSectionSeparator(.hidden)

            Section {
                DisclosureGroup("Optional Fields", isExpanded: $optionalSectionExpanded) {
                    OptionalTextFieldView(
                        textFieldText: $flashcard.hint,
                        SFSymbol: "lightbulb.min",
                        textFieldLabel: "Hints"
                    )
                    .focused($internalField, equals: .hints)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))

                    OptionalTextFieldView(
                        textFieldText: $flashcard.notes,
                        SFSymbol: "note.text",
                        textFieldLabel: "Notes"
                    )
                    .focused($internalField, equals: .notes)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 16))
                }
            }
            .listRowSeparator(.hidden)
            .listSectionSeparator(.hidden)

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
        // Control display of keyboard
        .onChange(of: internalField) { _, newField in
            focusedField = newField
        }
        .onChange(of: focusedField) { _, newBindingValue in
            internalField = newBindingValue
        }
    }

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

private struct FlashcardBodyTextField: View {
    @Binding var flashcardText: String
    let textFieldLabel: String

    var body: some View {
        TextField(textFieldLabel, text: $flashcardText, axis: .vertical)
            .lineLimit(3, reservesSpace: true)
            .padding(10)
            .clipDefaultShape()
            .overlay {
                RoundedRectangle(cornerRadius: DesignConstants.Layout.cornerRadius)
                    .stroke(.black, lineWidth: 1)
                    .shadow(color: .gray, radius: 0.5)
            }
    }
}

private struct OptionalTextFieldView: View {
    @Binding var textFieldText: String
    let SFSymbol: String
    let textFieldLabel: String

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

#if DEBUG
#Preview {
    NavigationStack {
        FlashcardFormView(
            flashcard: .constant(Flashcard.sampleFlashcard),
            focusedField: .constant(.frontText),
            showDeleteFlashcardButton: true
        )
    }
}
#endif
