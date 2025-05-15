//
//  LandingViewType.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Enum representing the different authentication-related views shown on the landing screen.

import Foundation

/// Represents the different authentication-related views shown on the landing screen.
enum LandingViewType: Equatable {
    /// Displays the title screen.
    case title
    /// Displays the login screen.
    case login
    /// Displays the sign-up screen.
    case signUp
    /// Displays the password reset screen.
    case passwordReset
    /// Displays the user profile screen.
    case userProfile

    /// Switches the current view type to the specified landing view type.
    ///  - Parameter landingViewType: The landing view type to switch to.
    mutating func switchTo(_ landingViewType: LandingViewType) {
        self = landingViewType
    }
}
