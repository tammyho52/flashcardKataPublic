//
//  AlertButtonHelper.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

struct AlertHelper {
    static func saveButton(action: @escaping () -> Void) -> Alert.Button {
        .destructive(Text("Save"), action: action)
    }
    
    
    static func deleteButton(action: @escaping () -> Void) -> Alert.Button {
        .destructive(Text("Delete"), action: action)
    }
    
    static func cancelButton(action: (() -> Void)? = nil) -> Alert.Button {
        .cancel(Text("Cancel"), action: action)
    }
}
