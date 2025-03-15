//
//  Toast.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Model to store information for toast notifications.

import Foundation
import SwiftUI

struct Toast: Equatable {
    var style: ToastStyle
    var message: String
    var duration: Double = 3
    var width: Double = .infinity
    var position: ToastPosition = .top
}

enum ToastPosition {
    case top, middle, bottom
}

enum ToastStyle {
    case error
    case warning
    case success
    case info
}

extension ToastStyle {
    var themeColor: Color {
        switch self {
        case .error:
            return Color.red
        case .warning:
            return Color.orange
        case .success:
            return Color.green
        case .info:
            return Color.blue
        }
    }

    var iconName: String {
        switch self {
        case .error:
            return "exclamationmark.octagon.fill"
        case .warning:
            return "exclamationmark.triangle.fill"
        case .success:
            return "checkmark.circle.fill"
        case .info:
            return "info.circle.fill"
        }
    }
}
