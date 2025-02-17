//
//  ValidationHelper.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation

struct ValidationHelper {
    
    static func isFieldEmpty(_ value: String, for fieldName: SignInSignUpField) -> String? {
        return value.isEmpty ? "\(fieldName.description) is required" : nil
    }
    
    static func isFieldTrue(_ condition: Bool, for fieldName: SignInSignUpField) -> String? {
        return condition == false ? "Please agree to the \(fieldName.description) to proceed." : nil
    }
}
