//
//  Color+Extensions.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Extension to convert SwiftUI Color to UIColor.

import SwiftUI
import UIKit

extension Color {
    var uiColor: UIColor {
        UIColor(self)
    }
}
