//
//  String+Extensions.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

extension String {
    func capitalizedFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    func pluralize(_ count: Int) -> String {
        if count == 1 {
            return self
        } else {
            return self + "s"
        }
    }
}
