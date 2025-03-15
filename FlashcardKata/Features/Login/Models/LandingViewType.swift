//
//  LandingViewType.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Enum for different landing view types.

import Foundation

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
