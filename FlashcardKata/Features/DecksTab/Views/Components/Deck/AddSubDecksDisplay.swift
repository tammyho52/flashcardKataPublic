//
//  AddSubDecksComponent.swift
//  FlashcardKata
//
//  Created by Tammy Ho
//
//  View that displays current subdecks with modify options.

import SwiftUI

struct AddSubDecksDisplay: View {
    @Binding var subdecksNames: [SubdeckName]

    let isEditView: Bool // Checks if view is used within an Edit View to allow for subdeck name edits.

    var body: some View {
        HStack {
            iconSideBanner
            SubDeckDisplay(
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

struct SubDeckDisplay: View {
    @State private var showEditSubdeckNameView: Bool = false
    @State private var selectedSubdeckName: SubdeckName?
    @State private var newSubdeckNameString: String = ""
    @Binding var subdecksNames: [SubdeckName]

    let isEditView: Bool

    var body: some View {
        ScrollView(showsIndicators: false) {
            if showEditSubdeckNameView {
                EditSubdeckNameView(
                    selectedSubdeckName: $selectedSubdeckName,
                    newSubdeckNameString: $newSubdeckNameString,
                    resetAndExit: resetAndExitEditSubdeckNameView,
                    updateSubdeckName: updateSubdeckName
                )
            } else {
                ForEach(subdecksNames) { subdeckName in
                    HStack {
                        deleteSubdeckButton(subdeckName: subdeckName)
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

    // MARK: - Helper Methods
    // Resets and leaves edit each subdeck name view.
    private func resetAndExitEditSubdeckNameView() {
        newSubdeckNameString = ""
        self.selectedSubdeckName = nil
        showEditSubdeckNameView = false
    }

    // Updates individual subdeck name.
    private func updateSubdeckName() {
        if let index = subdecksNames.firstIndex(where: { $0.id == selectedSubdeckName?.id}) {
            subdecksNames[index].name = newSubdeckNameString
        }
    }

    // Deletes subdeck.
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

#if DEBUG
#Preview {
    AddSubDecksDisplay(subdecksNames: .constant(SubdeckName.sampleSubdeckNameArray), isEditView: true)
}

#Preview {
    AddSubDecksDisplay(subdecksNames: .constant(SubdeckName.sampleSubdeckNameArray), isEditView: false)
}
#endif
