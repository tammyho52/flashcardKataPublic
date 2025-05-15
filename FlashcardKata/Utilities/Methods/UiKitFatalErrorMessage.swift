//
//  UIKitFatalErrorMessage.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Utility function to generate a fatal error message for UIKit instantiation.

import Foundation

/// Generates a fatal error message for UIKit instantiation.
func uiKitFatalErrorMessage(for viewName: String) -> String {
    return "\(viewName) cannot be instantiated from a Storyboard or XIB."
}
