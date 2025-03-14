//
//  DebouncerService.swift
//  FlashcardKata
//
//  Created by Tammy Ho.
//
//  Class that handles text validation with debouncing logic.

import Foundation

public final class DebouncerTextValidationService: ObservableObject {
    @Published private var debounceTimer: Timer?
    private let timeInterval: TimeInterval

    public init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }

    func debounceAndCheck(_ checkAction: @escaping () async throws -> Void) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { _ in
            Task {
                try await checkAction()
            }
        }
    }
}
