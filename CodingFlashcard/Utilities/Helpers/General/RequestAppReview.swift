//
//  RequestAppReview.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import StoreKit

func requestAppReview() {
    guard let currentScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
    SKStoreReviewController.requestReview(in: currentScene)
}
