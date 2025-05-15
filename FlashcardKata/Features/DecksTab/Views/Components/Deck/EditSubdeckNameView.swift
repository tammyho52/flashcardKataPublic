//
//  EditSubdeckNameView.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view that provides an interface for editing the name of a selected subdeck.

import SwiftUI

/// A view that allows users to edit the name of a selected subdeck.
struct EditSubdeckNameView: View {
    // MARK: - Properties
    @Binding var selectedSubdeckName: SubdeckName? // Current subdeck name to be edited
    @Binding var newSubdeckNameString: String // New subdeck name entered for the selected subdeck

    let resetAndExit: () -> Void
    let updateSubdeckName: () async -> Void
    
    // MARK: - Constants
    let symbolFontSize: CGFloat = 50
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 20) {
            if let selectedSubdeckName {
                VStack(spacing: 5) {
                    Text("Current Subdeck Name:")
                        .fontWeight(.semibold)
                    Text("\(selectedSubdeckName.name)")
                        .lineLimit(2, reservesSpace: true)
                }
                
                TextField("Enter new subdeck name", text: $newSubdeckNameString)
                    .modifier(TextFieldStyle(backgroundColor: .gray))
                
                HStack(spacing: 50) {
                    cancelButton
                    saveUpdatedSubdeckNameButton
                }
            }

        }
        .padding()
    }

    // MARK: - Helper Views
    private var cancelButton: some View {
        Button {
            withAnimation {
                resetAndExit()
            }
        } label: {
            Image(systemName: "x.circle.fill")
                .font(.system(size: symbolFontSize))
                .foregroundStyle(.red)
        }
    }

    private var saveUpdatedSubdeckNameButton: some View {
        Button {
            Task {
                await updateSubdeckName()
                withAnimation {
                    resetAndExit()
                }
            }
        } label: {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: symbolFontSize))
                .foregroundStyle(DesignConstants.Colors.primaryButtonBackground)
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    EditSubdeckNameView(
        selectedSubdeckName: .constant(SubdeckName(name: "Computer Software")),
        newSubdeckNameString: .constant(""),
        resetAndExit: {},
        updateSubdeckName: {}
    )
}
#endif
