//
//  DebouncerService.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  This class provides a debouncing mechanism for text validation, ensuring that validation logic is executed only after a specified delay.

import Foundation

public final class DebouncerTextValidationService: ObservableObject {
    // MARK: - Properties
    @Published private var debounceTimer: Timer?
    private let timeInterval: TimeInterval

    // MARK: - Initialization
    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }

    /// Debounces the provided action and executes it after the specified time interval.
    func debounceAndCheck(_ checkAction: @escaping () async throws -> Void) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
            Task {
                try await checkAction()
            }
        }
    }
}
