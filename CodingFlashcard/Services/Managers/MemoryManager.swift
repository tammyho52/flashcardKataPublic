//
//  MemoryManager.swift
//  CodingFlashcard
//
//  Created by Tammy Ho.
//

import Foundation
import UIKit

class MemoryManager {
    var clearAllCachesAction: () async throws -> Void
    
    init(clearAllCachesAction: @escaping () -> Void) {
        self.clearAllCachesAction = clearAllCachesAction
        NotificationCenter.default.addObserver(self, selector: #selector(handleMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)
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
