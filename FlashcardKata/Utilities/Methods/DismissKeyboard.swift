//
//  DismissKeyboard.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Utility function to dismiss the keyboard in a UIKit application.

import Foundation
import UIKit

/// Function to dismiss the keyboard.
func dismissKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
