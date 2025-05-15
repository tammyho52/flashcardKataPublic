//
//  BoldFont.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Utility function to create a bold version of a given font.

import UIKit

/// Boldens the given font by applying the bold trait.
func boldFont(from font: UIFont) -> UIFont {
    let fontDescriptor = font.fontDescriptor.withSymbolicTraits(.traitBold) ?? font.fontDescriptor
    return UIFont(descriptor: fontDescriptor, size: font.pointSize)
}
