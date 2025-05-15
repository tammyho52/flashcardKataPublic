//
//  MemoryManager.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This class observes memory warnings from the system and triggers a provided action to clear all caches when a memory warning is received.

import Foundation
import UIKit

/// A manager that observes memory warnings and executes a cache-clearing action.
class MemoryManager {
    var clearAllCachesAction: () async throws -> Void

    init(clearAllCachesAction: @escaping () -> Void) {
        self.clearAllCachesAction = clearAllCachesAction
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func handleMemoryWarning() {
        Task {
            try await clearAllCachesAction()
        }
    }
}
