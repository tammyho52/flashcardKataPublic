//
//  EditSubdeckNameView.swift
//  CodingFlashcard
//
//  Created by Tammy Ho
//

import SwiftUI

struct EditSubdeckNameView: View {
    @Binding var selectedSubdeckName: SubdeckName?
    @Binding var newSubdeckNameString: String
    
    let resetAndExit: () -> Void
    let updateSubdeckName: () async -> Void
    let imageFontSize: CGFloat = 50
    
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
                    .modifier(InputControlStyle(backgroundColor: .gray))
                HStack(spacing: 50) {
                    Button {
                        withAnimation {
                            resetAndExit()
                        }
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .font(.system(size: imageFontSize))
                            .foregroundStyle(.red)
                    }
                    
                    Button {
                        Task {
                            await updateSubdeckName()
                            withAnimation {
                                resetAndExit()
                            }
                        }
                    } label: {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: imageFontSize))
                            .foregroundStyle(DesignConstants.Colors.primaryButtonBackground)
                    }
                }
            }
            
        }
        .padding()
    }
}

#if DEBUG
#Preview {
    EditSubdeckNameView(selectedSubdeckName: .constant(SubdeckName(name: "Computer Software")), newSubdeckNameString: .constant(""), resetAndExit: {}, updateSubdeckName: {})
}
#endif
