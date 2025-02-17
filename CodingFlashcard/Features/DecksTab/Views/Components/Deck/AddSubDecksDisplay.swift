//
//  AddSubDecksComponent.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct AddSubDecksDisplay: View {
    @Binding var subdecksNames: [SubdeckName]
    
    let isEditView: Bool
    
    var body: some View {
        HStack {
            IconSideBanner
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
    
    var IconSideBanner: some View {
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
    @State private var selectedSubdeckName: SubdeckName? = nil
    @State private var newSubdeckNameString: String = ""
    @Binding var subdecksNames: [SubdeckName]
    
    let isEditView: Bool
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            if showEditSubdeckNameView {
                EditSubdeckNameView(
                    selectedSubdeckName: $selectedSubdeckName,
                    newSubdeckNameString: $newSubdeckNameString,
                    resetAndExit: resetAndExitEditSubdeckNameview,
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
    
    private func resetAndExitEditSubdeckNameview() {
        newSubdeckNameString = ""
        self.selectedSubdeckName = nil
        showEditSubdeckNameView = false
    }
    
    private func updateSubdeckName() {
        if let index = subdecksNames.firstIndex(where: { $0.id == selectedSubdeckName?.id} ) {
            subdecksNames[index].name = newSubdeckNameString
        }
    }
    
    private func deleteSubdeckButton(subdeckName: SubdeckName) -> some View {
        Button(action: {
            deleteSubdeckName(subdeckName)
        }) {
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
    
    private func deleteSubdeckName(_ subdeckName: SubdeckName) -> Void {
        if let index = subdecksNames.firstIndex(where: { $0.id == subdeckName.id }) {
            subdecksNames.remove(at: index)
        }
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
