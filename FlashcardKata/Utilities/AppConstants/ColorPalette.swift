//
//  ColorPalette.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Central repository for the color scheme of the app.

import SwiftUI

struct ColorPalette {

    struct Text {
        static let primary = Color("TextPrimary")
        static let secondary = Color("TextSecondary")
        static let background = Color.customAccent3
    }

    struct Button {
        static let primaryForeground = Color.white
        static let primaryBackground = Color.customSecondary

        static let secondaryForeground = Color.customPrimary
        static let secondaryBackground = Color.customAccent3

        static let disabled = Color.customLightGray.opacity(0.5)
    }

    struct Icon {
        static let primary = Color("CustomPrimary")
        static let secondary = Color("CustomSecondary")
    }

    struct TabBar {
        static let tint = Color("CustomSecondary")
    }

    struct Theme {
        static let darkBlue = Color("DarkBlue")
        static let darkSlateBlue = Color("DarkSlateBlue")
        static let darkGreen = Color("DarkGreen")
        static let darkOrange = Color("DarkOrange")
        static let darkPink = Color("DarkPink")
        static let darkPurple = Color("DarkPurple")
        static let darkRed = Color("DarkRed")
        static let darkTeal = Color("DarkTeal")
        static let darkYellow = Color("DarkYellow")
        static let darkGray = Color("DarkSoftGray")

        static let lightBlue = Color("LightBlue")
        static let lightSlateBlue = Color("LightSlateBlue")
        static let lightGreen = Color("LightGreen")
        static let lightOrange = Color("LightOrange")
        static let lightPink = Color("LightPink")
        static let lightPurple = Color("LightPurple")
        static let lightRed = Color("LightRed")
        static let lightTeal = Color("LightTeal")
        static let lightYellow = Color("LightYellow")
        static let lightGray = Color("LightSoftGray")
    }

}
