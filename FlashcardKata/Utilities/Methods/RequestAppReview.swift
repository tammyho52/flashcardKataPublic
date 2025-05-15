//
//  RequestAppReview.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Utility function that triggers the app review prompt from the App Store.

import StoreKit

/// Requests an app review from the user.
func requestAppReview() {
    guard let currentScene =
            UIApplication.shared.connectedScenes.first(where: {
                $0.activationState == .foregroundActive
            }) as? UIWindowScene else { return }
    SKStoreReviewController.requestReview(in: currentScene)
}
