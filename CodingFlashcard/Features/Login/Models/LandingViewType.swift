//
//  LandingViewType.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import SwiftUI

enum LandingViewType: Equatable {
    case title
    case login
    case signUp
    case passwordReset
    case userProfile
    
    mutating func switchTo(_ landingViewType: LandingViewType) {
        self = landingViewType
    }
}


