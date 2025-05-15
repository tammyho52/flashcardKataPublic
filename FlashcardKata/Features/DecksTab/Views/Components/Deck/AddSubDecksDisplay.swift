//
//  AddSubDecksComponent.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  A view that displays a list of subdecks with options to modify them, such as editing or deleting.

import SwiftUI

/// A view that displays a list of subdecks with an optional edit mode.
struct AddSubDecksDisplay: View {
    // MARK: - Properties
    @Binding var subdecksNames: [SubdeckName] // List of subdeck names.

    let isEditView: Bool // A flag indicating if the view is in edit mode.

    // MARK: - Body
    var body: some View {
        HStack {
            iconSideBanner // Displays a decorative icon and title on the side.
            SubdeckDisplay(
                subdecksNames: $subdecksNames,
                isEditView: isEditView
            )
        }
        .font(.customCallout)
        .clipDefaultShape()
        .frame(height: 250)
        .overlay {
            RoundedRectangle(cornerRadius: DesignConstants.Layout.cornerRadius)
                .stroke(.gray, lineWidth: 2.5)
        }
    }
    
    // MARK: - Helper Views
    ///  A decorative side banner displaying an icon and title.
    var iconSideBanner: some View {
        VStack {
            Text("Subdecks")
                .foregroundStyle(.white)
                .fontWeight(.semibold)
                .padding(5)
            Image(systemName: "rectangle.stack")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 50)
                .foregroundStyle(.white)
        }
        .frame(height: 250)
        .background(.gray)
    }
}

// MARK: - SubdeckDisplay
/// A view that displays a list of subdeck names with options to edit or delete them.
private struct SubdeckDisplay: View {
    @State private var showEditSubdeckNameView: Bool = false
    @State private var selectedSubdeckName: SubdeckName? // Currently selected subdeck name for editing.
    @State private var newSubdeckNameString: String = "" // New name for the subdeck in edit mode.
    @Binding var subdecksNames: [SubdeckName] // List of subdeck names.

    let isEditView: Bool

    var body: some View {
        ScrollView(showsIndicators: false) {
            if showEditSubdeckNameView {
                // Displays the edit subdeck name view if in edit mode.
                EditSubdeckNameView(
                    selectedSubdeckName: $selectedSubdeckName,
                    newSubdeckNameString: $newSubdeckNameString,
                    resetAndExit: resetAndExitEditSubdeckNameView,
                    updateSubdeckName: updateSubdeckName
                )
            } else {
                // Displays the list of subdeck names.
                ForEach(subdecksNames) { subdeckName in
                    HStack {
                        deleteSubdeckButton(subdeckName: subdeckName)
                        
                        // Edit button for the subdeck, shown only in edit mode.
                        if isEditView {
                            Button {
                                withAnimation {
                                    selectedSubdeckName = subdeckName
                                    newSubdeckNameString = subdeckName.name
                                    showEditSubdeckNameView = true
                                }
                            } label: {
                                Image(systemName: "pencil")
                                    .font(.title2)
                                    .padding(10)
                                    .foregroundStyle(DesignConstants.Colors.primaryButtonForeground)
                                    .background(DesignConstants.Colors.primaryButtonBackground)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(1)
                }
            }
        }
        .padding(5)
        .frame(maxWidth: .infinity)
        .zIndex(1)
    }

    // MARK: - Private Methods
    /// Resets the state and exits the edit subdeck name view.
    private func resetAndExitEditSubdeckNameView() {
        newSubdeckNameString = ""
        self.selectedSubdeckName = nil
        showEditSubdeckNameView = false
    }

    /// Updates the name of the selected subdeck.
    private func updateSubdeckName() {
        if let index = subdecksNames.firstIndex(where: { $0.id == selectedSubdeckName?.id}) {
            subdecksNames[index].name = newSubdeckNameString
        }
    }

    // MARK: - Helper Views
    /// Creates a button for deleting a subdeck.
    private func deleteSubdeckButton(subdeckName: SubdeckName) -> some View {
        Button {
            if let index = subdecksNames.firstIndex(where: { $0.id == subdeckName.id }) {
                subdecksNames.remove(at: index)
            }
        } label: {
            HStack {
                Spacer()
                Text(subdeckName.name)
                Spacer()
                Image(systemName: "x.circle")
                    .font(.title2)
            }
            .lineLimit(3)
            .foregroundStyle(.white)
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 15)
            .padding(.vertical, 7.5)
        }
        .background(.gray)
        .clipShape(Capsule())
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    AddSubDecksDisplay(subdecksNames: .constant(SubdeckName.sampleSubdeckNameArray), isEditView: true)
}

#Preview {
    AddSubDecksDisplay(subdecksNames: .constant(SubdeckName.sampleSubdeckNameArray), isEditView: false)
}
#endif
