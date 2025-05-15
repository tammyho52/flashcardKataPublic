//
//  AlertButtonHelper.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Helper structure that provides common alert buttons.

import SwiftUI

/// A helper structure that provides common alert buttons for use in SwiftUI alerts.
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
